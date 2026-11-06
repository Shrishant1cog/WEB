# Phase 4 Architecture

**Date:** 2026-11-07  
**Status:** Design Phase

---

## Core Design Principles

1. **Backward Compatibility** — Legacy `matches.team_a_id`/`team_b_id` and `results.team_id` remain for existing data; new code uses entry-based model
2. **Entry-Based Canonical Model** — `tournament_registrations` is the single source of truth for participation; `match_entries` links matches to registrations
3. **Server-Side Security** — All credential operations, result submission, dispute resolution through trusted `SECURITY DEFINER` RPCs
4. **RLS as Defense-in-Depth** — RPCs are primary authorization; RLS policies provide additional protection
5. **Immutable Audit** — `log_audit` for all state changes; credential access logged without secrets

---

## Database Schema (Migration 7)

### 1. `match_entries` — Canonical Match ↔ Registration Association

```sql
CREATE TABLE public.match_entries (
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    registration_id UUID NOT NULL REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    slot INTEGER,                    -- For BR: landing order; for CS: side (1/2)
    seed INTEGER,                    -- Bracket seed
    side TEXT,                       -- 'A' | 'B' for head-to-head modes
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by UUID REFERENCES public.profiles(id),
    PRIMARY KEY (match_id, registration_id)
);

-- Prevent duplicate assignment
CREATE UNIQUE INDEX ON public.match_entries (registration_id, match_id);
-- Ensure registration is confirmed
-- Enforced in RPC: registration must be confirmed, not withdrawn, same tournament

CREATE INDEX idx_match_entries_match ON public.match_entries(match_id);
CREATE INDEX idx_match_entries_registration ON public.match_entries(registration_id);

ALTER TABLE public.match_entries ENABLE ROW LEVEL SECURITY;
```

### 2. Extended `matches` Table

```sql
ALTER TABLE public.matches
    ADD COLUMN IF NOT EXISTS round_name TEXT,
    ADD COLUMN IF NOT EXISTS group_name TEXT,
    ADD COLUMN IF NOT EXISTS mode TEXT CHECK (mode IN ('br', 'cs', 'tdm', 'custom')),
    ADD COLUMN IF NOT EXISTS max_entries INTEGER,  -- For BR: max squads/players
    ADD COLUMN IF NOT EXISTS dispute_window_hours INTEGER DEFAULT 24;
    -- Legacy columns retained: team_a_id, team_b_id, winner_id, score_a, score_b
```

### 3. `match_room_secrets` — Encrypted Credentials

```sql
CREATE TABLE public.match_room_secrets (
    match_id UUID PRIMARY KEY REFERENCES public.matches(id) ON DELETE CASCADE,
    room_id_ciphertext BYTEA NOT NULL,
    room_password_ciphertext BYTEA NOT NULL,
    key_version INTEGER NOT NULL DEFAULT 1,
    nonce_id BYTEA NOT NULL,
    nonce_password BYTEA NOT NULL,
    release_at TIMESTAMPTZ NOT NULL,
    released_at TIMESTAMPTZ,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- No direct SELECT for clients; access via get_match_credentials RPC only
ALTER TABLE public.match_room_secrets ENABLE ROW LEVEL SECURITY;
```

### 4. `match_credential_access` — Access Audit

```sql
CREATE TABLE public.match_credential_access (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    registration_id UUID NOT NULL REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    access_granted BOOLEAN NOT NULL,
    release_at TIMESTAMPTZ NOT NULL,
    accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cred_access_match ON public.match_credential_access(match_id);
CREATE INDEX idx_cred_access_user ON public.match_credential_access(user_id);

ALTER TABLE public.match_credential_access ENABLE ROW LEVEL SECURITY;
```

### 5. Extended `results` Table

```sql
ALTER TABLE public.results
    ADD COLUMN IF NOT EXISTS registration_id UUID REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS rank INTEGER,
    ADD COLUMN IF NOT EXISTS kills INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS placement_points INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS kill_points INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS scoring_rules_snapshot JSONB,
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'provisional', 'disputed', 'finalized')),
    ADD COLUMN IF NOT EXISTS finalized_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS finalized_by UUID REFERENCES public.profiles(id);

-- Backfill registration_id from team_id where unambiguous (handled in migration)
-- Add unique constraint: one result per registration per match
CREATE UNIQUE INDEX IF NOT EXISTS uq_results_match_registration
    ON public.results (match_id, registration_id)
    WHERE registration_id IS NOT NULL;
```

### 5. `disputes` Table

```sql
CREATE TABLE public.disputes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    registration_id UUID NOT NULL REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    result_id UUID REFERENCES public.results(id) ON DELETE SET NULL,
    submitted_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    evidence_paths TEXT[] NOT NULL DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'submitted'
        CHECK (status IN ('submitted', 'under_review', 'resolved', 'rejected')),
    moderator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    resolution TEXT,
    resolution_type TEXT CHECK (resolution_type IN ('upheld', 'corrected', 'rejected')),
    old_result JSONB,
    new_result JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_disputes_match ON public.disputes(match_id);
CREATE INDEX idx_disputes_registration ON public.disputes(registration_id);
CREATE INDEX idx_disputes_moderator ON public.disputes(moderator_id);
CREATE INDEX idx_disputes_status ON public.disputes(status);

ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
```

### 6. `tournaments` Extensions

```sql
ALTER TABLE public.tournaments
    ADD COLUMN IF NOT EXISTS dispute_window_hours INTEGER DEFAULT 24,
    ADD COLUMN IF NOT EXISTS rules_config JSONB DEFAULT '{
        "placement_points": {},
        "kill_points": 0,
        "scoring_mode": "manual"
    }'::jsonb;
```

---

## RPC Interface

### Match Management

| RPC | Purpose | Auth |
|-----|---------|------|
| `create_match(tournament_id, round_name, group_name, match_number, mode, max_entries, scheduled_at)` | Create match | Organizer |
| `update_match(match_id, payload)` | Update match details | Organizer |
| `assign_match_entries(match_id, registration_ids[], slot[], side[])` | Assign entries | Organizer |
| `remove_match_entry(match_id, registration_id)` | Remove entry | Organizer |
| `reschedule_match(match_id, scheduled_at, reason)` | Reschedule | Organizer |
| `start_match(match_id)` | Mark in_progress | Organizer |
| `complete_match(match_id)` | Mark completed | Organizer |
| `cancel_match(match_id, reason)` | Cancel | Organizer |

### Credentials

| RPC | Purpose | Auth |
|-----|---------|------|
| `set_match_credentials(match_id, room_id, room_password, release_at)` | Set encrypted credentials | Organizer |
| `get_match_credentials(match_id)` | Retrieve (release-enforced) | Assigned participant |
| `rotate_match_credentials(match_id, room_id, room_password)` | Rotate credentials | Organizer |

### Results

| RPC | Purpose | Auth |
|-----|---------|------|
| `save_result_draft(match_id, registration_id, rank, kills, placement_points, kill_points, total_points, scoring_snapshot)` | Save draft | Organizer |
| `publish_provisional_results(match_id)` | Publish provisional | Organizer |
| `finalize_match_results(match_id)` | Finalize (checks disputes) | Organizer |
| `finalize_tournament_results(tournament_id)` | Compute standings | Organizer |
| `get_match_results(match_id)` | Read results | Participant/Organizer/Public (by status) |

### Disputes

| RPC | Purpose | Auth |
|-----|---------|------|
| `submit_dispute(match_id, registration_id, reason, evidence_paths[])` | Submit dispute | Eligible participant |
| `assign_dispute_moderator(dispute_id, moderator_id)` | Assign moderator | Organizer |
| `start_dispute_review(dispute_id)` | Begin review | Assigned moderator |
| `resolve_dispute(dispute_id, resolution_type, new_result?, explanation)` | Resolve | Assigned moderator |
| `reject_dispute(dispute_id, explanation)` | Reject | Assigned moderator |
| `get_assigned_disputes(tournament_id)` | Queue | Moderator |

### Credentials

| RPC | Purpose | Auth |
|-----|---------|------|
| `set_match_credentials(match_id, room_id, room_password, release_at)` | Set encrypted credentials | Organizer |
| `get_match_credentials(match_id)` | Retrieve with release check | Assigned participant |

---

## State Machines

### Match Lifecycle

```
scheduled → in_progress → completed
    ↓           ↓            ↓
cancelled  cancelled   cancelled
```

Transitions:
- `scheduled` → `in_progress`: `start_match` (organizer)
- `scheduled` → `cancelled`: `cancel_match` (organizer)
- `in_progress` → `completed`: `complete_match` (organizer)
- `in_progress` → `cancelled`: `cancel_match` (organizer)

### Result Lifecycle

```
draft → provisional → finalized
         ↓            ↓
       disputed  (corrected)
         ↓
     (back to provisional if corrected)
```

Transitions:
- `draft` → `provisional`: `publish_provisional_results` (organizer)
- `provisional` → `disputed`: `submit_dispute` (participant)
- `disputed` → `provisional`: `resolve_dispute` with correction (moderator)
- `disputed` → `finalized`: `resolve_dispute` upheld (moderator)
- `provisional` → `finalized`: `finalize_match_results` (organizer, after dispute window)

### Dispute Lifecycle

```
submitted → under_review → resolved
                ↓           ↓
              rejected   (corrected/upheld)
```

---

## Security Model

### Credential Encryption

- **Algorithm:** AES-256-GCM (via `pgcrypto` `encrypt`/`decrypt`)
- **Key Storage:** Supabase Vault (secret name: `match_cred_key_v1`)
- **Key Rotation:** Versioned in `match_room_secrets.key_version`
- **Nonce:** Random per field, stored alongside ciphertext

```sql
-- Encryption (server-side only)
room_id_ciphertext = pgp_sym_encrypt(room_id, vault_key)
room_password_ciphertext = pgp_sym_encrypt(room_password, vault_key)

-- Decryption (inside get_match_credentials RPC only)
room_id = pgp_sym_decrypt(room_id_ciphertext, vault_key)
```

### Release Enforcement

`get_match_credentials` RPC **must** verify:
1. `auth.uid()` is authenticated
2. User has confirmed registration assigned to this match (`match_entries`)
3. Registration not withdrawn/disqualified
4. Match not cancelled
5. `NOW() >= release_at`
6. Credentials exist

Only then: decrypt and return `{ room_id, room_password }`.

### Moderator Conflict Checks

Before assigning/acting on dispute:
1. Moderator ≠ `submitted_by`
2. Moderator ∉ `registration_id` roster (`tournament_entry_members`)
3. Moderator not organizer for same tournament (unless explicit exception)

---

## Error Codes (Extend `errors.ts`)

| Code | Message |
|------|---------|
| `MATCH_NOT_FOUND` | Match not found. |
| `MATCH_NOT_EDITABLE` | Match cannot be edited in current state. |
| `INVALID_MATCH_TRANSITION` | Invalid match state transition. |
| `ENTRY_NOT_ASSIGNED` | Registration not assigned to this match. |
| `ENTRY_ALREADY_ASSIGNED` | Registration already assigned to this match. |
| `INVALID_ENTRY_FOR_MATCH` | Registration not eligible for this match. |
| `CREDENTIALS_NOT_SET` | Room credentials not configured. |
| `CREDENTIALS_NOT_RELEASED` | Credentials not yet released. |
| `CREDENTIALS_ALREADY_RELEASED` | Credentials already released. |
| `RESULT_DRAFT_EXISTS` | Draft result already exists for this entry. |
| `RESULT_ALREADY_PROVISIONAL` | Results already published. |
| `RESULT_ALREADY_FINALIZED` | Results already finalized. |
| `DISPUTE_WINDOW_CLOSED` | Dispute submission deadline passed. |
| `DISPUTE_ALREADY_EXISTS` | Active dispute already exists for this result. |
| `MODERATOR_CONFLICT` | Moderator has conflict of interest. |
| `NOT_DISPUTE_MODERATOR` | You are not assigned to this dispute. |
| `DISPUTE_NOT_UNDER_REVIEW` | Dispute not in review state. |
| `CANNOT_FINALIZE_PENDING_DISPUTES` | Cannot finalize with open disputes. |

---

## Test Plan (Phase 4)

### Database Tests (pgTAP or integration)

1. Match CRUD + lifecycle
2. Entry assignment (solo + squad)
3. Duplicate assignment rejection
4. Waitlisted/withdrawn entry rejection
5. Credential set/get with release enforcement
6. Result draft/provisional/finalize
7. Dispute submit/review/resolve
8. Moderator conflict prevention
9. Finalization blocks (pending disputes)
10. Correction audit trail

### Web Tests (Vitest)

1. Match validation
2. Result validation
3. Dispute validation
4. Credential release timing
5. Organizer/moderator auth
6. Error mapping

### Flutter Tests

1. Match list/detail
2. Credential countdown
3. Result display
4. Dispute submission
5. Evidence upload
6. Error states

### E2E (Playwright)

1. Organizer creates match → assigns entries → sets credentials → participant retrieves after release
2. Result entry → provisional → dispute → moderator resolve → finalize
3. Tournament finalization after all matches

---

## Milestones

| Milestone | Deliverable |
|-----------|-------------|
| 4.1 | Migration 7 applied; match_entries, room_secrets, disputes tables; RLS; basic RPCs |
| 4.2 | Match CRUD, assignment, scheduling; web organizer UI; Flutter match list |
| 4.3 | Credential encryption, release enforcement; Flutter credential screen |
| 4.4 | Result draft/provisional/finalize; scoring validation |
| 4.5 | Dispute submission, evidence, moderator review, resolution |
| 4.6 | Match/tournament finalization; correction audit |
| 4.7 | Integration tests, security tests, docs, APK/build |