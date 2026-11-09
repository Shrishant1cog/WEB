# FCM Worker Authentication Setup

## Overview

The FCM delivery Edge Function is invoked by a pg_cron job every minute. It requires authentication to ensure only authorized cron workers can trigger FCM deliveries.

## Authentication Mechanism

### API Key-Based Authentication

The Edge Function (`supabase/functions/fcm-delivery/index.ts`) validates the API key by comparing it against a secret stored in Supabase Vault. The API key must:

1. **Be the Supabase service_role key** (from Dashboard → Settings → API)
2. **Match the Vault secret** `fcm_worker_key` exactly

The service_role key is an **opaque API key** (not a JWT). The Edge Function validates it by simple string comparison against the Vault secret.

### Why This Approach?

- **No JWT complexity** - The service_role key is an opaque API key, not a JWT
- **No JWT verification complexity** - No JWKS, no audience/issuer checks needed
- **Works for all key formats** - Works for both legacy JWT and new `sb_` prefixed keys
- **Simple and auditable** - Direct string comparison is transparent and auditable

## Deployment Steps

### 1. Enable Required Extensions

In Supabase Dashboard → Database → Extensions:
- Enable `pg_cron`
- Enable `pg_net`

### 2. Run Migrations

```bash
# Apply migrations (includes Vault helper functions and cron job definitions)
supabase db push
```

### 3. Store Service Role Key in Vault

The service_role key from Supabase Dashboard is used directly as the API key.

**Option A: Via Supabase Dashboard SQL Editor**
```sql
SELECT vault.create_secret('fcm_worker_key', '<your-service-role-key>');
```

**Option B: Via Supabase CLI (requires linked project)**
```bash
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
supabase db exec "SELECT vault.create_secret('fcm_worker_key', '<your-service-role-key>');"
```

Or use the helper script:
```bash
deno run --allow-env --allow-run supabase/scripts/store_fcm_worker_key.ts
```

### 4. Deploy Edge Function

```bash
supabase functions deploy fcm-delivery
```

### 5. Set Edge Function Secrets

In Supabase Dashboard → Edge Functions → `fcm-delivery` → Settings → Secrets:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL` (from Firebase service account)
- `FIREBASE_PRIVATE_KEY` (from Firebase service account, PKCS#8 format)
- `FCM_WORKER_API_KEY` = `<your-service-role-key>`

### 5. Enable Cron Jobs

Run the following SQL in Supabase Dashboard → SQL Editor:

```sql
-- 1. Process scheduled notifications (every minute)
SELECT cron.schedule(
    'process-scheduled-notifications',
    '* * * * *', -- every minute
    $$ SELECT public.process_scheduled_notifications(100); $$
);

-- 2. Process FCM delivery via Edge Function (every minute)
SELECT cron.schedule(
    'process-fcm-delivery',
    '* * * * *', -- every minute
    $$
    SELECT net.http_post(
        url := 'https://<project-ref>.supabase.co/functions/v1/fcm-delivery',
        headers := fcm_internal.get_fcm_worker_auth_header(),
        body := '{}'::jsonb
    ) AS response;
    $$
);

-- 3. Cleanup old processed deliveries (daily at 3 AM)
SELECT cron.schedule(
    'cleanup-notification-delivery-queue',
    '0 3 * * *', -- daily at 3 AM
    $$
    DELETE FROM public.notification_delivery_queue
    WHERE status IN ('sent', 'dead')
      AND updated_at < NOW() - INTERVAL '7 days';
    $$
);

-- 4. Cleanup old scheduled notifications (daily at 4 AM)
SELECT cron.schedule(
    'cleanup-scheduled-notifications',
    '0 4 * * *', -- daily at 4 AM
    $$
    DELETE FROM public.scheduled_notifications
    WHERE processed_at IS NOT NULL
      AND processed_at < NOW() - INTERVAL '30 days';
    $$
);
```

Replace `<project-ref>` with your Supabase project reference (e.g., `zjwgqjjgqbkunzhghdtb`).

### 6. Verify Deployment

**Check cron jobs:**
```sql
SELECT * FROM cron.job;
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
```

**Test Edge Function:**
```bash
curl -X POST \
  -H "apikey: <your-service-role-key>" \
  -H "Content-Type: application/json" \
  https://<project-ref>.supabase.co/functions/v1/fcm-delivery
```

Expected response: `{"processed":0,"message":"No pending deliveries"}` (if queue is empty)

## Security Notes

- **Never hardcode** the service_role key in migrations or code
- The API key is stored in **Supabase Vault** (encrypted at rest)
- Only the `service_role` can read the Vault secret (via `SECURITY DEFINER` functions in `fcm_internal` schema)
- The Edge Function validates the key by **exact string comparison** against the Vault secret
- The service_role key is never exposed to the client or cron job directly (retrieved via SECURITY DEFINER function)

## Files

- `supabase/migrations/20261109000001_phase5_fcm_worker_auth.sql` — Vault helper functions in `fcm_internal` schema
- `supabase/migrations/20261108000017_phase5_scheduled_jobs.sql` — Cron job definitions
- `supabase/functions/fcm-delivery/index.ts` — Edge Function
- `supabase/scripts/store_fcm_worker_key.ts` — Helper script to store key in Vault
- `supabase/config.toml` — Edge Function config with `verify_jwt = false`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "FCM worker key not configured in Vault" | Run the Vault secret creation SQL |
| "Unauthorized: invalid or missing worker API key" | Check `apikey` header format; ensure `FCM_WORKER_API_KEY` matches Vault secret |
| "FCM credentials not configured" | Set Firebase secrets in Edge Function settings |
| Cron job not running | Check `pg_cron` and `pg_net` extensions are enabled |
| Edge Function returns 500 | Check Edge Function logs: `supabase functions logs fcm-delivery` |

## Architecture

```
┌─────────────────┐     pg_cron      ┌──────────────────┐
│  pg_cron job    │ ───────────────▶ │  pg_net HTTP     │
│  (every minute) │                   │  POST to Edge    │
└─────────────────┘                   │  Function        │
                                      └────────┬─────────┘
                                               │
                                               ▼
                                    ┌──────────────────┐
                                    │  Supabase Vault  │
                                    │  (get API key)   │
                                    └────────┬─────────┘
                                               │
                                    ┌──────────▼──────────┐
                                    │  fcm_internal.get_  │
                                    │  fcm_worker_        │
                                    │  auth_header()      │
                                    └──────────┬──────────┘
                                               │
                                               ▼
                                    ┌──────────────────┐
                                    │  apikey: <key>   │
                                    │  Content-Type:   │
                                    │  application/json│
                                    └────────┬─────────┘
                                               │
                                               ▼
                                    ┌──────────────────┐
                                    │  Edge Function   │
                                    │  (key compare)   │
                                    └──────────────────┘
```

## Key Security Properties

1. **No hardcoded secrets** - API key stored in Vault, retrieved at runtime
2. **Least privilege** - Only `service_role` can execute Vault helper functions
3. **Simple validation** - Exact string comparison, no complex JWT logic
5. **Schema isolation** - Helper functions in `fcm_internal` schema, not public
6. **Short-lived cron execution** - Runs every minute, minimal attack surface
7. **Audit trail** - All cron executions logged in `cron.job_run_details`

## Migration from JWT Approach

| Aspect | JWT Approach (Previous) | API Key Approach (Current) |
|--------|------------------------|---------------------------|
| Key Format | JWT (legacy) or opaque API key (new) | Opaque API key (both legacy & new) |
| Verification | JWKS + asymmetric keys | Exact string comparison |
| Audience Check | Required (`fcm-worker`) | Not needed |
| Key Storage | Vault (as JWT) | Vault (as opaque key) |
| Compatibility | Legacy JWT only | Both legacy & new keys |
| Complexity | High (JWT parsing, JWKS) | Low (string compare) |