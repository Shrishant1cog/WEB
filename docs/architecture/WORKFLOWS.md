# Workflows — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline workflows for implementation

---

## 1. Player Registration & Authentication Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌────────────┐
│   Launch    │────►│  Register    │────►│  Email Verify   │────►│  Profile   │
│   App       │     │  (email/pass)│     │  (link click)   │     │  Setup     │
└─────────────┘     └──────────────┘     └─────────────────┘     └────────────┘
                           │                    │                    │
                           ▼                    ▼                    ▼
                    ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
                    │ Supabase Auth│     │ Auth confirms│     │ Create profile│
                    │ creates user │     │ email_verified│    │ row, consent │
                    │ (unverified) │     │ = true       │     │ records      │
                    └──────────────┘     └──────────────┘     └──────────────┘
```

**Key Points:**
- Email verification required before tournament registration
- Password recovery: secure reset link (expires 1 hour, single-use)
- Session: JWT in secure httpOnly cookie (web) / secure storage (mobile)
- Refresh token rotation enabled
- Logout revokes refresh token

---

## 2. Tournament Creation Flow (Organizer)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Org Dashboard│────►│ Create Draft │────►│ Configure    │────►│ Publish      │
│  "New Tourn." │     │ Tournament   │     │ Rules/Dates  │     │ Tournament   │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  Auth: org member   Insert tournaments   Validate:           Update status:
  (owner/admin)      row (status=draft)   - dates ordered     'published'
                     Org FK set           - capacity > 0      Notify followers
                     created_by = user    - roster_size > 0   (optional)
```

**State Transitions (Validated by DB Function):**
```
draft → published → registration_open → registration_closed → scheduled → live → provisional_results → dispute_period → finalized
                    ↑                    ↑
                    └──── cancel ───────┘
```

---

## 3. Player Tournament Discovery & Registration

### 3.1 Discovery
```
Public Tournament Listing (no auth)
    │
    ▼
GET /rpc/get_public_tournaments(filters)
    │
    ├── Filters: status, format, date_range, search_text
    ├── Returns: id, title, format, status, dates, capacity, registered_count
    └── RLS: Only status IN ('published', 'registration_open', 'registration_closed', 'scheduled', 'live')
```

### 3.2 Solo Registration
```
Player views tournament detail (authenticated)
    │
    ├── Check eligibility (age, region, not already registered)
    ├── Check status = registration_open
    ├── Check capacity (registered < capacity)
    │
    ▼
POST /rpc/register_tournament_entry(tournament_id)
    │
    ▼
DB Function (SECURITY DEFINER, transactional):
    ├── LOCK tournament row FOR UPDATE
    ├── Re-verify all conditions
    ├── INSERT tournament_entries (status=confirmed)
    ├── INSERT audit_event
    ├── IF capacity now full: notify waitlisters (via trigger)
    └── RETURN entry_id, status
    │
    ▼
Trigger → notification_event → Edge Function → Push + In-app
```

### 3.3 Squad Registration (Captain)
```
Captain creates/manages team
    │
    ├── Team must have exactly roster_size active members
    ├── All members must have accepted invitations
    ├── Captain = team creator (transferable)
    │
    ▼
Captain registers team for tournament
    │
    ▼
POST /rpc/register_tournament_entry(tournament_id, team_id)
    │
    ▼
DB Function:
    ├── LOCK tournament FOR UPDATE
    ├── Verify captain = caller
    ├── Verify team.tournament_id IS NULL (not registered elsewhere)
    ├── Verify team active members = roster_size
    ├── Verify all members eligible
    ├── INSERT tournament_entries (team_id, captain_id)
    ├── UPDATE teams SET tournament_id = ...
    ├── INSERT entry_members (roster snapshot)
    ├── INSERT audit_event
    └── RETURN entry_id
```

---

## 4. Team Management Flow

```
Create Team (Captain)
    │
    ├── INSERT teams (captain_id = current_user)
    ├── INSERT team_memberships (captain, active)
    └── RETURN team_id
    │
    ▼
Invite Players
    │
    ├── Captain enters player email/username
    ├── Generate secure random token (32 bytes)
    ├── INSERT team_invitations (token_hash = sha256(token))
    ├── Send invitation link: /team/invite/{token}
    ├── Rate limit: 10/hr, 50/day per captain
    │
    ▼
Player Accepts Invitation
    │
    ├── GET /team/invite/{token} → verify token_hash, not expired, not used
    ├── INSERT team_memberships (member, active, added_by = captain)
    ├── UPDATE team_invitations SET accepted_at = now()
    ├── Notify captain
    │
    ▼
Team Ready (roster_size active members)
    │
    └── Captain can register for squad tournament
```

---

## 5. Waitlist & Promotion Flow

```
Tournament at capacity
    │
    Player attempts registration
    │
    ▼
DB Function register_tournament_entry:
    ├── Capacity full
    ├── INSERT waitlist_entries (position = MAX(position)+1)
    ├── status = 'waiting'
    ├── RETURN entry_id, status='waitlisted', position
    │
    ▼
Player withdraws / Entry disqualified
    │
    ▼
Trigger on tournament_entries (UPDATE status to withdrawn/disqualified)
    │
    ▼
CALL promote_waitlist(tournament_id)
    │
    ▼
DB Function promote_waitlist:
    ├── LOCK tournament FOR UPDATE
    ├── SELECT * FROM waitlist_entries 
    │   WHERE tournament_id = $1 AND status = 'waiting'
    │   ORDER BY position LIMIT 1 FOR UPDATE SKIP LOCKED
    ├── IF found:
    │   ├── UPDATE waitlist_entries SET status='promoted', promoted_at=now()
    │   ├── INSERT tournament_entries (from waitlist roster_snapshot)
    │   ├── INSERT entry_members (if squad)
    │   ├── INSERT audit_event
    │   ├── RETURN promoted_entry_id
    │   └── Trigger notification → promoted player
    └── ELSE: no action
```

---

## 6. Match & Room Credential Flow

### 6.1 Organizer Sets Credentials
```
Organizer → Match Management → "Set Credentials"
    │
    ├── Input: room_id, password, release_at
    ├── Validate: release_at ≥ now() + 5 min, ≤ match.scheduled_at
    │
    ▼
POST /rpc/set_match_credentials(match_id, room_id, password, release_at)
    │
    ▼
DB Function:
    ├── Verify caller = tournament organizer (owner/admin)
    ├── ENCRYPT room_id, password (pgcrypto, key from vault)
    ├── INSERT/UPDATE match_room_secrets
    ├── Schedule release (pg_cron or Edge Function at release_at)
    ├── INSERT audit_event (action='credential.set', no password logged)
    └── RETURN success
```

### 6.2 Credential Release (Automated)
```
At release_at (Edge Function / pg_cron):
    │
    ▼
UPDATE match_room_secrets SET released_at = now(), released_by = 'system'
WHERE match_id = $1 AND released_at IS NULL
    │
    ▼
Trigger → notification_event for all confirmed entries in tournament
    │
    ▼
Edge Function send-notification:
    ├── For each confirmed entry: create notification
    ├── Queue push delivery (notification_outbox)
```

### 6.3 Player Retrieves Credentials
```
Player → Match Detail → "Get Room Info" (after release time)
    │
    ▼
POST /rpc/get_match_credentials(match_id)
    │
    ▼
DB Function:
    ├── Verify caller has confirmed entry in tournament
    ├── Verify match_room_secrets.released_at IS NOT NULL
    ├── DECRYPT room_id, password
    ├── INSERT audit_event (action='credential.access', profile_id, match_id)
    └── RETURN {room_id, password}
```

---

## 7. Results & Disputes Flow

### 7.1 Provisional Results
```
Match completes
    │
    Organizer → Match Detail → "Enter Results"
    │
    ├── Input: per-entry rank, score, kills, points
    │
    ▼
POST /rpc/submit_provisional_results(match_id, results_json[])
    │
    ▼
DB Function:
    ├── Verify organizer ownership
    ├── INSERT tournament_results (is_provisional=true)
    ├── UPDATE matches SET status='completed'
    ├── Schedule dispute_period_end = now() + tournament_rules.dispute_window_hours
    ├── INSERT audit_event
    └── Trigger notifications to participants
```

### 7.2 Dispute Submission
```
Player views provisional results (within dispute window)
    │
    ├── "File Dispute" → form: reason, evidence (screenshots)
    ├── Upload evidence to Supabase Storage (private bucket, signed URL)
    │
    ▼
POST /rpc/submit_dispute(result_id, reason, evidence_urls[])
    │
    ▼
DB Function:
    ├── Verify caller = participant in result_id.entry_id
    ├── Verify now() < dispute_period_end
    ├── INSERT disputes (status='submitted')
    ├── Assign moderator (round-robin from platform_staff_roles WHERE role='moderator' AND scope includes tournament)
    ├── INSERT audit_event
    ├── Notify moderator + tournament organizer
    └── RETURN dispute_id
```

### 7.3 Moderator Resolution
```
Moderator → Dispute Queue → Review evidence
    │
    ├── Decision: uphold / reject / correct
    ├── If correct: provide corrected_results_json
    │
    ▼
POST /rpc/resolve_dispute(dispute_id, resolution, corrected_results_json?)
    │
    ▼
DB Function:
    ├── Verify caller = assigned_moderator
    ├── Verify no conflict of interest (moderator not participant in tournament)
    ├── UPDATE disputes SET status='resolved'/'rejected', resolution, resolved_at, resolved_by
    ├── IF corrected_results_json:
    │   ├── UPDATE tournament_results SET ... (corrected values)
    │   ├── INSERT audit_event (action='result.corrected', old_value, new_value, moderator_id)
    ├── INSERT audit_event (action='dispute.resolved')
    └── Notify submitter + organizer
```

### 7.4 Finalization
```
At dispute_period_end (or manual by organizator if no disputes):
    │
    ▼
POST /rpc/finalize_results(tournament_id)
    │
    ▼
DB Function:
    ├── Verify no pending disputes (status IN ('submitted','under_review'))
    ├── UPDATE tournament_results SET is_provisional=false, finalized_at=now()
    ├── UPDATE tournaments SET status='finalized'
    ├── INSERT audit_event (action='results.finalized')
    ├── Notify all participants
    └── RETURN finalized results
```

---

## 8. Account Deletion Flow

```
Player → Settings → "Delete Account"
    │
    ├── In-app: Confirm password + understand consequences
    ├── Web: /account-deletion → email → verification link
    │
    ▼
POST /rpc/initiate_account_deletion()
    │
    ▼
DB Function:
    ├── INSERT account_deletion_requests (status='pending')
    ├── Send verification email (custom SMTP)
    ├── RETURN request_id
    │
    ▼
Email verification link clicked
    │
    ▼
Edge Function verify-deletion-token:
    ├── UPDATE account_deletion_requests SET status='verifying', verified_at=now()
    ├── Schedule deletion job (delay 24h for cooling off)
    │
    ▼
Edge Function process-account-deletion (after delay):
    ├── UPDATE status='processing'
    ├── CALL supabase.auth.admin.delete_user(profile_id)
    ├── Anonymize/profile data: profiles (display_name='Deleted User', avatar=null, in_game_*=null, deleted_at=now())
    ├── Soft-delete: tournaments (if owner, transfer or cancel), teams (disband), entries (withdraw)
    ├── Retain: audit_events (legal), consent_records (legal), account_deletion_requests
    ├── Document retention_exceptions in request record
    ├── UPDATE status='completed', completed_at=now()
    └── Notify user (email) that deletion complete
```

---

## 9. Notification Delivery Flow

```
Event occurs (registration, credential release, result, dispute, etc.)
    │
    ▼
DB Trigger on source table → INSERT notification + notification_outbox (channels: in_app, push)
    │
    ▼
Edge Function send-notification (triggered by pg_notify or cron)
    │
    ├── For each outbox item:
    │   ├── in_app: already inserted (notification row)
    │   ├── push: GET device_tokens FOR profile → FCM send → UPDATE outbox
    │   ├── email: (future) SMTP send → UPDATE outbox
    │
    ▼
Retry logic (Edge Function cron every 5 min):
    ├── SELECT * FROM notification_outbox WHERE status='pending' AND attempts < 3
    ├── Retry failed deliveries
    ├── Max 3 attempts, exponential backoff
    └── After 3 failures: status='failed', alert admin
```

---

## 10. Admin Workflows

### 10.1 Organizer Approval
```
New organization created (status='pending')
    │
    ▼
Admin → Organizer Management → Review
    │
    ├── Check: contact email verified, legitimate purpose
    ├── Approve: UPDATE organizations SET status='approved', approved_by=admin, approved_at=now()
    ├── Suspend: UPDATE status='suspended'
    │
    ▼
INSERT audit_event (action='organization.approve/suspend')
Notify organization owner
```

### 10.2 Moderator Assignment
```
Admin → Moderator Management
    │
    ├── Select profile, role=moderator
    ├── Define scope: {"tournaments": ["uuid"], "organizations": ["uuid"]}
    ├── INSERT platform_staff_roles
    │
    ▼
INSERT audit_event
Notify new moderator
```

---

## 11. Error Handling & Compensation

| Scenario | Detection | Compensation |
|----------|-----------|--------------|
| Registration double-submit | Idempotency key / DB unique constraint | Return existing entry_id |
| Capacity race condition | DB function FOR UPDATE locking | Waitlist insertion |
| Credential early access attempt | get_match_credentials checks release_at | 403 Forbidden |
| Dispute after window | submit_dispute checks dispute_period_end | 400 Bad Request |
| Moderator conflict | resolve_dispute checks platform_staff_roles scope | 403 Forbidden |
| Push delivery failure | notification_outbox status=failed after 3 retries | Alert admin, fallback to in-app only |
| Account deletion partial failure | process-account-deletion tracks per-table | Retry failed tables, manual intervention flag |

---

## 12. Concurrency Control Summary

| Operation | Mechanism |
|-----------|-----------|
| Tournament registration | `LOCK tournament FOR UPDATE` in RPC |
| Waitlist promotion | `FOR UPDATE SKIP LOCKED` on waitlist_entries |
| Credential release | Single UPDATE with `WHERE released_at IS NULL` |
| Result submission | Organizer-only, no concurrent writers per match |
| Dispute resolution | Moderator-assigned, single writer per dispute |
| Profile updates | Optimistic locking via `updated_at` check |