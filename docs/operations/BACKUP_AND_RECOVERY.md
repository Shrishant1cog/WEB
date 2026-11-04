# Backup & Recovery — FFT

**Version:** 1.0  
**Date:** 5 November 2026  
**Status:** Baseline for Phase 7-8

---

## 1. Backup Strategy Overview

| Data Type | Method | Frequency | Retention | Location | RPO | RTO |
|-----------|--------|-----------|-----------|----------|-----|-----|
| **PostgreSQL (Primary)** | Supabase PITR (WAL) | Continuous | 7 days (Pro) / 30 days (Team) | Supabase managed (same region) | ~1 second | Minutes |
| **PostgreSQL (Logical)** | `pg_dump` via cron | Daily 02:00 UTC | 30 days | S3-compatible (separate account) | 24 hours | Hours |
| **Supabase Storage** | S3 versioning + replication | Continuous | 90 days | Supabase managed (same region) | ~0 | Minutes |
| **Auth Users** | Included in PITR | Continuous | Same as DB | Supabase managed | ~1 second | Minutes |
| **Edge Functions** | Git (source control) | Per commit | Forever | GitHub | 0 | Minutes |
| **Configuration** | Git (secrets in Vault) | Per commit | Forever | GitHub + Supabase Vault | 0 | Minutes |
| **Application Code** | Git | Per commit | Forever | GitHub | 0 | Minutes |

---

## 2. Supabase Point-in-Time Recovery (PITR)

### 2.1 How It Works

- Supabase runs PostgreSQL with WAL archiving
- Base backup + WAL segments = restore to any second
- Managed by Supabase, no configuration needed on Pro+ plans

### 2.2 Recovery Procedure

```bash
# Via Supabase Dashboard:
# 1. Go to Database → Backups
# 2. Click "Restore" on desired backup
# 3. Select "Point in time recovery"
# 4. Choose timestamp (UTC)
# 4. Confirm → New project created with restored data
# 5. Update DNS / connection strings to new project
# 6. Verify application works
# 7. Delete old project after confirmation
```

### 2.3 RPO/RTO Targets

| Tier | RPO | RTO | Cost |
|------|-----|-----|------|
| **Supabase Pro** | ~1 second | ~15 minutes | $25/mo |
| **Supabase Team** | ~1 second | ~10 minutes | $599/mo |
| **Supabase Enterprise** | ~1 second | ~5 minutes | Custom |

**MVP Target:** Supabase Pro (upgrade if RTO insufficient)

---

## 3. Logical Backups (pg_dump)

### 3.1 Daily Backup Script (Edge Function / Cron)

```sql
-- supabase/functions/backup-database/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // pg_dump via Supabase CLI not available in Edge Functions
  // Use external backup service or pg_dump from compute instance
  // This is a placeholder for external backup job
  
  return new Response(JSON.stringify({ status: 'triggered' }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### 3.2 External Backup (Recommended)

```bash
# Run from dedicated backup VM or GitHub Actions scheduled workflow
# Daily at 02:00 UTC

pg_dump \
  --host=<db-host> \
  --port=5432 \
  --username=postgres \
  --dbname=postgres \
  --format=custom \
  --compress=9 \
  --no-owner \
  --no-privileges \
  --file=fft_backup_$(date +%Y%m%d_%H%M%S).dump

# Upload to S3-compatible storage
aws s3 cp fft_backup_*.dump s3://fft-backups/prod/daily/ \
  --storage-class GLACIER_IR \
  --metadata retention=30d
```

### 3.3 Restore from Logical Backup

```bash
# 1. Download backup
aws s3 cp s3://fft-backups/prod/daily/fft_backup_20261105_020000.dump .

# 2. Create clean database (or use Supabase `supabase db reset` equivalent)
# 3. Restore
pg_restore \
  --host=<db-host> \
  --port=5432 \
  --username=postgres \
  --dbname=postgres \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  fft_backup_20261105_020000.dump

# 4. Verify row counts, constraints
# 5. Update application connection
```

---

## 4. Storage Backup

### 4.1 Supabase Storage (Automatic)

- S3 versioning enabled by default
- Cross-region replication: Not configured for MVP (cost)
- Manual download for critical files:

```bash
# List buckets
supabase storage ls

# Download bucket (requires supabase-cli with storage support)
# Or use AWS CLI with Supabase S3 credentials
aws s3 sync s3://<project-ref>/storage/ ./storage-backup/ --endpoint-url=https://<region>.supabase.co
```

### 4.2 Critical Files (Room Credentials, Evidence)

- Already in PostgreSQL (encrypted) or Storage with versioning
- No separate backup needed beyond DB + Storage

---

## 5. Configuration & Secrets Backup

### 5.1 Git (Source of Truth)

- All migrations, functions, code in Git
- Secrets: Supabase Vault (not in Git)
- Environment configs: Documented in `.env.example`

### 5.2 Supabase Vault (Secrets)

```bash
# List secrets (requires service role)
supabase secrets list

# Backup secrets (manual, encrypted)
supabase secrets list --output json > secrets_backup_$(date +%Y%m%d).json
# Encrypt before storing
gpg --encrypt --recipient <backup-key> secrets_backup_*.json
```

### 5.3 Restore Secrets

```bash
# Decrypt
gpg --decrypt secrets_backup_20261105.json.gpg > secrets.json

# Import (manual via dashboard or CLI)
# Supabase CLI doesn't support bulk secret import yet
# Use Dashboard → Settings → Vault
```

---

## 6. Disaster Recovery Scenarios

### 6.1 Scenario: Database Corruption / Accidental DROP

**Detection:** Application errors, monitoring alerts  
**Response:**
1. Confirm issue (check Supabase status page)
2. Initiate PITR to timestamp before corruption
3. New project created with restored data
4. Update `SUPABASE_URL` and keys in Vercel/mobile config
5. Deploy application (or restart with new config)
6. Verify critical paths (auth, tournaments, credentials)
7. Post-incident review

**Estimated RTO:** 15-30 minutes (PITR + deploy)

### 6.2 Scenario: Supabase Regional Outage

**Detection:** Supabase status page, application errors  
**Response:**
1. Confirm regional outage
2. If multi-region configured: failover to standby
3. MVP (single region): Wait for Supabase recovery
4. Communicate status via status page / social
5. No data loss (PITR continues in background)

**MVP Mitigation:** Document single-region limitation. Plan multi-region for post-MVP.

### 6.3 Scenario: Accidental Data Deletion (Application Bug)

**Detection:** User reports, audit log review  
**Response:**
1. Identify affected rows/tables via `audit_events`
2. If recent (<7 days): PITR to before deletion
3. If older: Restore from logical backup + replay WAL (complex)
4. For specific rows: Use `audit_events.old_value` to reconstruct
5. Apply targeted restore via SQL

**Prevention:** Soft deletes (`deleted_at`), no hard DELETE policies

### 6.4 Scenario: Secrets Compromise

**Detection:** Unauthorized access, unusual activity  
**Response:**
1. Rotate all compromised secrets immediately
2. Revoke all sessions (`supabase auth admin revoke-all-sessions`)
3. Audit `audit_events` for unauthorized access
4. Notify users if PII exposed (DPDP 72-hour rule)
5. Post-incident: Improve secret management

**Rotation Checklist:**
- [ ] Supabase service role key
- [ ] JWT secret (Supabase managed)
- [ ] pgcrypto encryption key
- [ ] FCM server key
- [ ] SMTP credentials
- [ ] Sentry DSN
- [ ] GitHub deploy keys

### 6.5 Scenario: Complete Account Deletion Bug

**Detection:** User reports data not deleted  
**Response:**
1. Check `account_deletion_requests` status
2. Identify which tables not processed
3. Run manual cleanup for missed tables
4. Update `retention_exceptions` with reason
5. Fix Edge Function workflow
6. Re-test with synthetic account

---

## 7. Recovery Testing

| Test | Frequency | Method | Success Criteria |
|------|-----------|--------|------------------|
| **PITR Restore** | Monthly | Supabase Dashboard → Restore to new project | New project functional, data consistent |
| **Logical Backup Restore** | Quarterly | `pg_restore` to staging | Row counts match, constraints valid |
| **Secrets Rotation** | Quarterly | Rotate all secrets, verify app works | No downtime, all services connect |
| **Full DR Drill** | Bi-annually | Simulate regional outage, failover | RTO < 30 min, RPO < 1 min |
| **Account Deletion** | Per release | E2E test with synthetic user | All PII removed, audit retained |

### 7.1 Monthly PITR Test Script

```bash
#!/bin/bash
# monthly-pitr-test.sh

set -e

TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
PROJECT_REF="your-prod-ref"
RESTORE_NAME="fft-pitr-test-${TIMESTAMP}"

echo "Starting PITR test at $(date)"

# 1. Initiate restore via Supabase API
# (Requires Management API token)
curl -X POST "https://api.supabase.com/v1/projects/${PROJECT_REF}/backups/restore" \
  -H "Authorization: Bearer ${SUPABASE_MANAGEMENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"timestamp\": \"$(date -u -d '1 hour ago' --iso-8601=seconds)\", \"name\": \"${RESTORE_NAME}\"}"

# 2. Poll for completion
# 3. Run verification queries against restored project
# 4. Clean up test project
# 5. Report results

echo "PITR test completed at $(date)"
```

---

## 8. Monitoring & Alerting for Backup Health

| Metric | Alert Threshold | Channel |
|--------|-----------------|---------|
| PITR lag | > 5 minutes | PagerDuty |
| Logical backup size | > 2x expected | Slack |
| Logical backup age | > 26 hours | PagerDuty |
| Storage replication lag | > 1 hour (if configured) | Slack |
| Vault secret rotation | > 90 days | Slack |
| Account deletion failures | > 0 in 24h | PagerDuty |

---

## 9. Documentation & Runbooks

### 9.1 Required Runbooks

1. **PITR Restore Runbook** — Step-by-step with screenshots
2. **Logical Backup Restore Runbook** — `pg_restore` procedure
3. **Secrets Rotation Runbook** — Per-secret procedure
4. **Regional Failover Runbook** — When multi-region configured
5. **Data Deletion Recovery Runbook** — Using audit logs

### 9.2 Runbook Template

```markdown
# Runbook: [Name]

**Trigger:** [What initiates this runbook]
**Owner:** [Team/person responsible]
**Severity:** [P1/P2/P3]
**Estimated Duration:** [Time]

## Prerequisites
- [ ] Access to Supabase Dashboard
- [ ] Access to AWS/S3 for backups
- [ ] Management API token

## Procedure
1. Step 1...
2. Step 2...

## Verification
- [ ] Check 1
- [ ] Check 2

## Rollback
If procedure fails: [Rollback steps]

## Post-Incident
- [ ] Update runbook
- [ ] Schedule retrospective
```

---

## 10. Compliance & Audit

| Requirement | Implementation | Evidence |
|-------------|----------------|----------|
| DPDP: Data localization | Mumbai region + backup in India | Supabase region config |
| DPDP: Retention enforcement | Automated disposal jobs | Cron logs, audit_events |
| DPDP: Breach notification | 72-hour alerting | Incident response playbook |
| Google Play: Account deletion | In-app + web, documented | Test reports |
| SOC 2 (future) | Supabase compliance + app controls | Audit reports |

---

## 11. Cost Estimation (Monthly)

| Component | Pro Plan | Team Plan | Notes |
|-----------|----------|-----------|-------|
| Supabase (DB, Auth, Storage, Functions) | $25 | $599 | Pro sufficient for MVP |
| PITR (included) | $0 | $0 | 7 days Pro, 30 days Team |
| Logical backup storage (S3 Glacier IR) | ~$5 | ~$20 | 30 daily dumps ~5GB each |
| Backup compute (GitHub Actions) | Free | Free | 2000 min/mo free |
| **Total** | **~$30** | **~$620** | |

**Recommendation:** Start Pro, monitor usage, upgrade when needed.