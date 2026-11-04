# Data Model — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline schema for Phase 1-4

---

## 1. Entity Relationship Overview

```
profiles ◄──────────────────────────────────────────────────────────────┐
    │                                                                   │
    ├── organizer_memberships ──► organizations                         │
    │                                                                   │
    ├── platform_staff_roles (moderator/admin)                          │
    │                                                                   │
    ├── teams ◄────────────────────────────────────────────────────────┤
    │    │                                                              │
    │    ├── team_memberships (player ↔ team)                           │
    │    └── team_invitations (token_hash, expires_at, used_at)         │
    │                                                                   │
    ├── tournament_entries ◄──────────────────────────────────────────┤
    │    │                                                              │
    │    └── entry_members (roster snapshot at registration)            │
    │                                                                   │
    ├── waitlist_entries (FIFO per tournament)                          │
    │                                                                   │
    ├── disputes (player ↔ tournament/match)                            │
    │                                                                   │
    ├── notifications (in-app)                                          │
    │                                                                   │
    ├── device_tokens (FCM)                                             │
    │                                                                   │
    ├── consent_records (DPDP)                                          │
    │                                                                   │
    └── account_deletion_requests                                       │
    
organizations ◄─────────────────────────────────────────────────────────┘
    │
    └── tournaments
         │
         ├── tournament_rules (JSONB configuration)
         │
         ├── matches
         │    └── match_room_secrets (encrypted, restricted)
         │
         ├── tournament_results (provisional → finalized)
         │
         └── audit_events (tournament-scoped)
```

---

## 2. Core Tables

### 2.1 profiles

**Purpose:** Player/organizer/admin profile data (extends Supabase auth.users)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, FK → auth.users(id) | User identifier |
| display_name | text | NOT NULL, 1-50 chars | Public display name |
| avatar_url | text | NULLABLE | Supabase Storage signed URL path |
| in_game_name | text | NULLABLE, 1-30 chars | Free Fire India in-game name |
| in_game_uid | text | NULLABLE, UNIQUE | Free Fire India UID (collected when needed) |
| privacy_profile_visibility | enum | NOT NULL DEFAULT 'public' | public / organizers_only / private |
| privacy_show_in_game_info | boolean | NOT NULL DEFAULT false | Show in-game name/UID to organizers |
| notification_prefs | jsonb | NOT NULL DEFAULT '{}' | Per-type preferences (in_app, push, email) |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | Auto-updated by trigger |
| deleted_at | timestamptz | NULLABLE | Soft delete for account deletion |

**Indexes:** `idx_profiles_in_game_uid` (unique, where not null), `idx_profiles_display_name` (trigram for search)

**RLS Policies:**
- `SELECT`: authenticated users can view public profiles; organizers can view profiles in their tournaments
- `UPDATE`: users can update own profile
- `DELETE`: soft delete only via account deletion flow

---

### 2.2 organizations

**Purpose:** Organizer group/entity that owns tournaments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| name | text | NOT NULL, 1-100 chars, UNIQUE | Organization name |
| description | text | NULLABLE | |
| logo_url | text | NULLABLE | Storage path |
| contact_email | text | NOT NULL | Verified email for communications |
| website_url | text | NULLABLE | |
| status | enum | NOT NULL DEFAULT 'pending' | pending / approved / suspended |
| approved_by | uuid | FK → profiles(id), NULLABLE | Admin who approved |
| approved_at | timestamptz | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**RLS Policies:**
- `SELECT`: members of organization + admins
- `INSERT`: authenticated users (create org → pending)
- `UPDATE`: organization members (name, description, logo) + admins (status)
- `DELETE`: admins only

---

### 2.3 organizer_memberships

**Purpose:** Link profiles to organizations with roles

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| organization_id | uuid | FK → organizations(id), NOT NULL | |
| profile_id | uuid | FK → profiles(id), NOT NULL | |
| role | enum | NOT NULL DEFAULT 'member' | owner / admin / member |
| invited_by | uuid | FK → profiles(id), NULLABLE | |
| invited_at | timestamptz | NOT NULL DEFAULT now() | |
| accepted_at | timestamptz | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Unique Constraint:** `(organization_id, profile_id)`

**RLS Policies:**
- `SELECT`: organization members + admins
- `INSERT`: organization owners/admins (invite)
- `UPDATE`: self (accept invitation), owners/admins (role changes)
- `DELETE`: self (leave), owners/admins (remove member)

---

### 2.4 platform_staff_roles

**Purpose:** Platform-level moderator/admin roles (scoped)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| profile_id | uuid | FK → profiles(id), NOT NULL, UNIQUE | |
| role | enum | NOT NULL | moderator / admin |
| scope | jsonb | NOT NULL DEFAULT '{}' | {"tournaments": ["uuid"], "organizations": ["uuid"]} |
| granted_by | uuid | FK → profiles(id), NOT NULL | |
| granted_at | timestamptz | NOT NULL DEFAULT now() | |
| revoked_at | timestamptz | NULLABLE | |
| is_active | boolean | GENERATED ALWAYS AS (revoked_at IS NULL) STORED | |

**RLS Policies:**
- `SELECT`: self + admins
- `INSERT/UPDATE/DELETE`: admins only

---

### 2.5 tournaments

**Purpose:** Core tournament entity

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| organization_id | uuid | FK → organizations(id), NOT NULL | |
| created_by | uuid | FK → profiles(id), NOT NULL | |
| title | text | NOT NULL, 1-200 chars | |
| description | text | NULLABLE | Markdown supported |
| format | enum | NOT NULL | solo / squad |
| roster_size | integer | NOT NULL DEFAULT 4 | Active players per squad (configurable) |
| max_substitutes | integer | NOT NULL DEFAULT 0 | MVP = 0 |
| mode | text | NOT NULL | e.g., 'Battle Royale', 'Clash Squad' |
| map | text | NULLABLE | |
| status | enum | NOT NULL DEFAULT 'draft' | draft / published / registration_open / registration_closed / scheduled / check_in / live / provisional_results / dispute_period / finalized / cancelled |
| capacity | integer | NOT NULL | Max entries (solo=players, squad=teams) |
| registration_opens_at | timestamptz | NOT NULL | |
| registration_closes_at | timestamptz | NOT NULL | |
| check_in_opens_at | timestamptz | NULLABLE | MVP: nullable |
| check_in_closes_at | timestamptz | NULLABLE | |
| starts_at | timestamptz | NOT NULL | Tournament start |
| ends_at | timestamptz | NOT NULL | Tournament end |
| timezone | text | NOT NULL DEFAULT 'Asia/Kolkata' | IANA timezone |
| rules_markdown | text | NULLABLE | Full rules |
| eligibility_criteria | jsonb | NOT NULL DEFAULT '{}' | Age, region, rank restrictions |
| prize_description | text | NULLABLE | Non-monetary only |
| cancelled_at | timestamptz | NULLABLE | |
| cancellation_reason | text | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**Indexes:** `idx_tournaments_org_status` (org_id, status), `idx_tournaments_dates` (registration_opens_at, starts_at), `idx_tournaments_public_discovery` (status, format, starts_at) WHERE status IN ('published', 'registration_open', 'registration_closed', 'scheduled', 'live')

**Check Constraints:** `registration_opens_at < registration_closes_at < starts_at < ends_at`, `capacity > 0`, `roster_size > 0`

**RLS Policies:**
- `SELECT`: public for published+; organizers see own org tournaments; admins see all
- `INSERT`: organization members (owner/admin)
- `UPDATE`: organization owners/admins (with state transition validation)
- `DELETE`: admins only (soft cancel via status)

---

### 2.6 tournament_rules

**Purpose:** Structured tournament configuration (extends tournaments)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| tournament_id | uuid | PK, FK → tournaments(id) | |
| config | jsonb | NOT NULL | Structured rules: scoring, tiebreakers, match settings, credential_release_policy, dispute_window_hours, etc. |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**RLS:** Same as tournaments (via join)

---

### 2.7 teams

**Purpose:** Player-formed teams for squad tournaments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| name | text | NOT NULL, 1-50 chars | Team name |
| tag | text | NULLABLE, 2-5 chars, UNIQUE | Short tag (optional) |
| captain_id | uuid | FK → profiles(id), NOT NULL | |
| tournament_id | uuid | FK → tournaments(id), NULLABLE | NULL = standalone team; set on registration |
| avatar_url | text | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |
| disbanded_at | timestamptz | NULLABLE | |

**Unique Constraint:** `(tournament_id, name)` WHERE tournament_id IS NOT NULL

**RLS Policies:**
- `SELECT`: team members + tournament organizers (if registered) + admins
- `INSERT`: authenticated users (create standalone team)
- `UPDATE`: captain (name, tag, avatar) + organizers (tournament_id on registration)
- `DELETE`: captain (if no tournament registration) + admins

---

### 2.8 team_memberships

**Purpose:** Team roster with history

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| team_id | uuid | FK → teams(id), NOT NULL | |
| profile_id | uuid | FK → profiles(id), NOT NULL | |
| role | enum | NOT NULL DEFAULT 'member' | captain / member |
| joined_at | timestamptz | NOT NULL DEFAULT now() | |
| left_at | timestamptz | NULLABLE | |
| is_active | boolean | GENERATED ALWAYS AS (left_at IS NULL) STORED | |
| added_by | uuid | FK → profiles(id), NOT NULL | Who added (captain or self via invite) |

**Unique Constraint:** `(team_id, profile_id)` WHERE is_active = true

**RLS Policies:**
- `SELECT`: team members + tournament organizers (if registered) + admins
- `INSERT`: captain (direct add — requires invitation acceptance first) OR self (accept invitation)
- `UPDATE`: captain (role change), self (leave team)
- `DELETE`: captain (remove member), self (leave)

---

### 2.9 team_invitations

**Purpose:** Secure team join invitations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| team_id | uuid | FK → teams(id), NOT NULL | |
| invited_profile_id | uuid | FK → profiles(id), NOT NULL | |
| invited_by | uuid | FK → profiles(id), NOT NULL | |
| token_hash | text | NOT NULL | sha256(random_token) |
| expires_at | timestamptz | NOT NULL DEFAULT now() + interval '7 days' | |
| accepted_at | timestamptz | NULLABLE | |
| revoked_at | timestamptz | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Indexes:** `idx_team_invitations_token_hash` (unique), `idx_team_invitations_team_pending` (team_id, invited_profile_id) WHERE accepted_at IS NULL AND revoked_at IS NULL

**RLS Policies:**
- `SELECT`: invited user (own invitations), captain, admins
- `INSERT`: captain (rate limited via trigger)
- `UPDATE`: invited user (accept), captain (revoke)
- `DELETE`: captain, admins

**Rate Limit Trigger:** Max 10 pending invitations per captain per hour; max 50 per day

---

### 2.10 tournament_entries

**Purpose:** Confirmed tournament registrations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| tournament_id | uuid | FK → tournaments(id), NOT NULL | |
| team_id | uuid | FK → teams(id), NULLABLE | NULL for solo; required for squad |
| profile_id | uuid | FK → profiles(id), NOT NULL | Solo player or captain |
| status | enum | NOT NULL DEFAULT 'confirmed' | confirmed / withdrawn / disqualified |
| registered_at | timestamptz | NOT NULL DEFAULT now() | |
| withdrawn_at | timestamptz | NULLABLE | |
| withdrawal_reason | text | NULLABLE | |
| roster_snapshot | jsonb | NOT NULL | Array of {profile_id, in_game_name, in_game_uid} at registration |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Unique Constraints:**
- Solo: `(tournament_id, profile_id)` WHERE team_id IS NULL
- Squad: `(tournament_id, team_id)` WHERE team_id IS NOT NULL
- Player uniqueness: Partial unique index via trigger/function — no profile in two entries same tournament

**RLS Policies:**
- `SELECT`: participant (own), team members, tournament organizers, admins
- `INSERT`: Via RPC function only (register_tournament_entry)
- `UPDATE`: Organizers (disqualify), participant (withdraw — if permitted)
- `DELETE`: Never (audit trail)

---

### 2.11 entry_members

**Purpose:** Roster snapshot for squad entries (denormalized for audit)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| entry_id | uuid | FK → tournament_entries(id), NOT NULL | |
| profile_id | uuid | FK → profiles(id), NOT NULL | |
| in_game_name | text | NOT NULL | Snapshot |
| in_game_uid | text | NOT NULL | Snapshot |
| position | integer | NOT NULL | 1 = captain, 2-4 = members |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Unique Constraint:** `(entry_id, profile_id)`

**RLS:** Same as tournament_entries (via join)

---

### 2.12 waitlist_entries

**Purpose:** FIFO waitlist for full tournaments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| tournament_id | uuid | FK → tournaments(id), NOT NULL | |
| team_id | uuid | FK → teams(id), NULLABLE | NULL for solo |
| profile_id | uuid | FK → profiles(id), NOT NULL | |
| position | integer | NOT NULL | 1 = next to promote |
| status | enum | NOT NULL DEFAULT 'waiting' | waiting / promoted / expired / withdrawn |
| joined_at | timestamptz | NOT NULL DEFAULT now() | |
| promoted_at | timestamptz | NULLABLE | |
| expired_at | timestamptz | NULLABLE | |
| withdrawn_at | timestamptz | NULLABLE | |
| roster_snapshot | jsonb | NOT NULL | Same as entry_members |

**Unique Constraint:** `(tournament_id, profile_id)` WHERE status = 'waiting' (via partial index)

**RLS Policies:**
- `SELECT`: own waitlist entry, tournament organizers, admins
- `INSERT`: Via RPC function only (register_tournament_entry when full)
- `UPDATE`: System (promotion), participant (withdraw)
- `DELETE`: Never

---

### 2.13 matches

**Purpose:** Tournament matches

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| tournament_id | uuid | FK → tournaments(id), NOT NULL | |
| round_name | text | NOT NULL | e.g., 'Group A', 'Quarterfinals' |
| match_number | integer | NOT NULL | Order within round |
| scheduled_at | timestamptz | NOT NULL | |
| estimated_duration_minutes | integer | NOT NULL DEFAULT 60 | |
| status | enum | NOT NULL DEFAULT 'scheduled' | scheduled / credential_released / live / completed / cancelled |
| format_override | jsonb | NULLABLE | Per-match format exceptions |
| created_by | uuid | FK → profiles(id), NOT NULL | Organizer |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**Unique Constraint:** `(tournament_id, round_name, match_number)`

**Indexes:** `idx_matches_tournament_scheduled` (tournament_id, scheduled_at)

**RLS Policies:**
- `SELECT`: public for published tournaments; organizers own; admins
- `INSERT/UPDATE`: Tournament organizers (owner/admin)
- `DELETE`: Organizers (if not started), admins

---

### 2.14 match_room_secrets

**Purpose:** Encrypted room credentials (RESTRICTED ACCESS)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| match_id | uuid | PK, FK → matches(id) | |
| room_id_encrypted | bytea | NOT NULL | pgcrypto encrypted |
| room_password_encrypted | bytea | NOT NULL | pgcrypto encrypted |
| release_at | timestamptz | NOT NULL | Organizer-configured release time |
| released_at | timestamptz | NULLABLE | Actual release time |
| released_by | uuid | FK → profiles(id), NULLABLE | System or organizer |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| created_by | uuid | FK → profiles(id), NOT NULL | Organizer who set credentials |

**RLS Policies:**
- `SELECT`: **NO direct SELECT policy** — only via SECURITY DEFINER function `get_match_credentials(match_id, profile_id)`
- `INSERT/UPDATE`: Tournament organizers via RPC `set_match_credentials`
- `DELETE`: Never

**Note:** This table has NO standard RLS policies. Access ONLY through controlled functions.

---

### 2.15 tournament_results

**Purpose:** Match/tournament results (provisional → finalized)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| tournament_id | uuid | FK → tournaments(id), NOT NULL | |
| match_id | uuid | FK → matches(id), NULLABLE | NULL for overall tournament results |
| entry_id | uuid | FK → tournament_entries(id), NOT NULL | |
| rank | integer | NULLABLE | 1 = winner |
| score | integer | NULLABLE | |
| kills | integer | NULLABLE | |
| placement_points | integer | NULLABLE | |
| kill_points | integer | NULLABLE | |
| total_points | integer | NULLABLE | |
| is_provisional | boolean | NOT NULL DEFAULT true | |
| finalized_at | timestamptz | NULLABLE | |
| finalized_by | uuid | FK → profiles(id), NULLABLE | Moderator |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**Unique Constraint:** `(match_id, entry_id)` WHERE match_id IS NOT NULL; `(tournament_id, entry_id)` WHERE match_id IS NULL

**RLS Policies:**
- `SELECT`: Public for finalized; participants + organizers for provisional
- `INSERT`: Organizers (provisional), Moderators (finalized corrections via RPC)
- `UPDATE`: Moderators via RPC `resolve_dispute` / `finalize_results` only
- `DELETE`: Never

---

### 2.16 disputes

**Purpose:** Player-submitted result disputes

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| tournament_id | uuid | FK → tournaments(id), NOT NULL | |
| match_id | uuid | FK → matches(id), NULLABLE | |
| result_id | uuid | FK → tournament_results(id), NOT NULL | |
| submitted_by | uuid | FK → profiles(id), NOT NULL | |
| assigned_moderator | uuid | FK → profiles(id), NULLABLE | |
| reason | text | NOT NULL | Dispute reason |
| evidence_urls | text[] | NOT NULL DEFAULT '{}' | Storage paths (signed URLs) |
| status | enum | NOT NULL DEFAULT 'submitted' | submitted / under_review / resolved / rejected |
| resolution | text | NULLABLE | Moderator decision |
| resolved_at | timestamptz | NULLABLE | |
| resolved_by | uuid | FK → profiles(id), NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**Check Constraint:** `submitted_by` must be participant in `entry_id` linked via `result_id`

**RLS Policies:**
- `SELECT`: Submitter, assigned moderator, tournament organizers, admins
- `INSERT`: Confirmed participants (within dispute window)
- `UPDATE`: Assigned moderator (resolve), admins
- `DELETE`: Never

---

### 2.17 notifications

**Purpose:** In-app notification events (persisted)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| profile_id | uuid | FK → profiles(id), NOT NULL | Recipient |
| type | enum | NOT NULL | registration_confirmed / waitlist_promoted / match_scheduled / credentials_released / result_published / dispute_update / announcement / system |
| title | text | NOT NULL | |
| body | text | NOT NULL | |
| data | jsonb | NOT NULL DEFAULT '{}' | Deep link params, entity IDs |
| read_at | timestamptz | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Indexes:** `idx_notifications_profile_unread` (profile_id, read_at) WHERE read_at IS NULL; `idx_notifications_created` (created_at DESC)

**RLS Policies:**
- `SELECT`: Own notifications only
- `INSERT`: System (via trigger/Edge Function)
- `UPDATE`: Self (mark read)
- `DELETE`: Self (after retention period), admins

---

### 2.18 notification_outbox

**Purpose:** Reliable notification delivery (push + in-app)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| notification_id | uuid | FK → notifications(id), NOT NULL | |
| channel | enum | NOT NULL | push / in_app / email |
| status | enum | NOT NULL DEFAULT 'pending' | pending / sent / failed |
| attempts | integer | NOT NULL DEFAULT 0 | |
| last_attempt_at | timestamptz | NULLABLE | |
| error_message | text | NULLABLE | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| sent_at | timestamptz | NULLABLE | |

**RLS:** Internal only (service role via Edge Function)

---

### 2.19 device_tokens

**Purpose:** FCM device tokens for push notifications

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| profile_id | uuid | FK → profiles(id), NOT NULL | |
| token | text | NOT NULL | FCM token |
| platform | enum | NOT NULL | android / ios / web |
| app_version | text | NOT NULL | |
| device_id_hash | text | NOT NULL | sha256(device_id) for deduplication |
| active | boolean | NOT NULL DEFAULT true | |
| last_used_at | timestamptz | NOT NULL DEFAULT now() | |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Unique Constraint:** `(profile_id, device_id_hash)`

**RLS Policies:**
- `SELECT/INSERT/UPDATE`: Own tokens only
- `DELETE`: Own tokens (logout), system (cleanup inactive > 90 days)

---

### 2.20 audit_events

**Purpose:** Immutable audit trail for sensitive operations

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| actor_id | uuid | FK → profiles(id), NOT NULL | Who performed action |
| action | text | NOT NULL | e.g., 'tournament.publish', 'entry.register', 'credential.release' |
| entity_type | text | NOT NULL | tournament / entry / match / result / dispute / team |
| entity_id | uuid | NOT NULL | |
| old_value | jsonb | NULLABLE | Previous state |
| new_value | jsonb | NULLABLE | New state |
| metadata | jsonb | NOT NULL DEFAULT '{}' | IP, user agent, correlation_id |
| created_at | timestamptz | NOT NULL DEFAULT now() | |

**Indexes:** `idx_audit_actor` (actor_id, created_at DESC), `idx_audit_entity` (entity_type, entity_id, created_at DESC)

**RLS Policies:**
- `SELECT`: Actor (own), admins, organization members (for org-scoped entities)
- `INSERT`: System only (triggers, RPC functions)
- `UPDATE/DELETE`: Never (immutable)

**Trigger:** Automatic on sensitive tables (tournaments, entries, matches, match_room_secrets, results, disputes, teams)

---

### 2.21 consent_records

**Purpose:** DPDP consent tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| profile_id | uuid | FK → profiles(id), NOT NULL | |
| purpose | enum | NOT NULL | tournament_registration / notifications_marketing / analytics / third_party_sharing |
| granted | boolean | NOT NULL | |
| granted_at | timestamptz | NULLABLE | |
| revoked_at | timestamptz | NULLABLE | |
| version | text | NOT NULL | Privacy policy version |
| ip_address | inet | NULLABLE | |
| user_agent | text | NULLABLE | |

**Unique Constraint:** `(profile_id, purpose, version)` WHERE revoked_at IS NULL

**RLS Policies:**
- `SELECT`: Own consents + admins
- `INSERT/UPDATE`: Self (grant/revoke) + system (auto-grant on registration)

---

### 2.22 account_deletion_requests

**Purpose:** Account deletion workflow tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() | |
| profile_id | uuid | FK → profiles(id), NOT NULL, UNIQUE | |
| status | enum | NOT NULL DEFAULT 'pending' | pending / verifying / processing / completed / failed |
| requested_at | timestamptz | NOT NULL DEFAULT now() | |
| verified_at | timestamptz | NULLABLE | Email verification completed |
| processed_at | timestamptz | NULLABLE | Deletion executed |
| completed_at | timestamptz | NULLABLE | All systems confirmed |
| failure_reason | text | NULLABLE | |
| retention_exceptions | jsonb | NOT NULL DEFAULT '{}' | Legal/operational data retained {table: reason} |
| created_at | timestamptz | NOT NULL DEFAULT now() | |
| updated_at | timestamptz | NOT NULL DEFAULT now() | |

**RLS Policies:**
- `SELECT`: Own request + admins
- `INSERT`: Self (initiate deletion)
- `UPDATE`: System (Edge Function workflow)
- `DELETE`: Never

---

## 3. Enums (PostgreSQL Types)

```sql
CREATE TYPE profile_visibility AS ENUM ('public', 'organizers_only', 'private');
CREATE TYPE organization_status AS ENUM ('pending', 'approved', 'suspended');
CREATE TYPE org_member_role AS ENUM ('owner', 'admin', 'member');
CREATE TYPE platform_role AS ENUM ('moderator', 'admin');
CREATE TYPE tournament_format AS ENUM ('solo', 'squad');
CREATE TYPE tournament_status AS ENUM (
    'draft', 'published', 'registration_open', 'registration_closed',
    'scheduled', 'check_in', 'live', 'provisional_results',
    'dispute_period', 'finalized', 'cancelled'
);
CREATE TYPE entry_status AS ENUM ('confirmed', 'withdrawn', 'disqualified');
CREATE TYPE waitlist_status AS ENUM ('waiting', 'promoted', 'expired', 'withdrawn');
CREATE TYPE match_status AS ENUM ('scheduled', 'credential_released', 'live', 'completed', 'cancelled');
CREATE TYPE dispute_status AS ENUM ('submitted', 'under_review', 'resolved', 'rejected');
CREATE TYPE notification_type AS ENUM (
    'registration_confirmed', 'waitlist_promoted', 'match_scheduled',
    'credentials_released', 'result_published', 'dispute_update',
    'announcement', 'system'
);
CREATE TYPE notification_channel AS ENUM ('push', 'in_app', 'email');
CREATE TYPE delivery_status AS ENUM ('pending', 'sent', 'failed');
CREATE TYPE device_platform AS ENUM ('android', 'ios', 'web');
CREATE TYPE consent_purpose AS ENUM (
    'tournament_registration', 'notifications_marketing',
    'analytics', 'third_party_sharing'
);
CREATE TYPE deletion_status AS ENUM ('pending', 'verifying', 'processing', 'completed', 'failed');
```

---

## 4. Key Database Functions (RPC)

| Function | Purpose | Security |
|----------|---------|----------|
| `register_tournament_entry(tournament_id, team_id?)` | Race-safe registration with capacity check, waitlist | SECURITY DEFINER, validates caller = profile_id or captain |
| `promote_waitlist(tournament_id)` | Atomic FIFO promotion when capacity frees | SECURITY DEFINER, called by trigger/Edge Function |
| `set_match_credentials(match_id, room_id, password, release_at)` | Encrypt and store credentials | SECURITY DEFINER, verifies organizer ownership |
| `get_match_credentials(match_id)` | Decrypt and return credentials if released + authorized | SECURITY DEFINER, verifies confirmed participant + release_time |
| `submit_provisional_results(match_id, results_json)` | Organizer submits results | SECURITY DEFINER, verifies organizer ownership |
| `submit_dispute(result_id, reason, evidence_urls)` | Player submits dispute | SECURITY DEFINER, verifies participant + dispute window |
| `resolve_dispute(dispute_id, resolution, corrected_results_json)` | Moderator resolves dispute | SECURITY DEFINER, verifies assigned moderator + no conflict |
| `finalize_results(tournament_id)` | Finalize all results after dispute period | SECURITY DEFINER, verifies all disputes resolved |
| `initiate_account_deletion()` | Start deletion workflow | SECURITY DEFINER, verifies authenticated user |
| `export_user_data()` | DPDP data export | SECURITY DEFINER, verifies authenticated user |

---

## 5. Retention Schedule

| Table | Retention | Deletion Trigger |
|-------|-----------|------------------|
| profiles | Account deletion + 30 days grace | account_deletion_requests.completed |
| tournament_entries | 3 years after tournament finalized | Tournament finalized + 3 years |
| match_room_secrets | 30 days after tournament finalized | Tournament finalized + 30 days |
| disputes | 3 years after resolution | Dispute resolved + 3 years |
| notifications | 90 days | Created + 90 days |
| audit_events | 7 years | Created + 7 years (legal) |
| consent_records | 7 years after revocation | Revoked + 7 years |
| device_tokens | 90 days inactive | last_used_at + 90 days |

---

## 6. Migration Strategy

1. **Baseline migration (001):** Enums, core tables (profiles, organizations, organizer_memberships, platform_staff_roles)
2. **Tournament migration (002):** tournaments, tournament_rules, matches, match_room_secrets
3. **Team/Registration migration (003):** teams, team_memberships, team_invitations, tournament_entries, entry_members, waitlist_entries
4. **Results/Disputes migration (004):** tournament_results, disputes
5. **Notifications migration (005):** notifications, notification_outbox, device_tokens
6. **Audit/Compliance migration (006):** audit_events, consent_records, account_deletion_requests
7. **RLS/Policies migration (007):** All RLS policies, triggers, indexes
8. **Functions migration (008):** All SECURITY DEFINER RPC functions
9. **Seed migration (009):** Development seed data (dev only)

Each migration: `up.sql` + `down.sql` (where reversible), tested in CI with `supabase db reset`.