# FCM Worker Authentication Setup

## Overview

The FCM delivery Edge Function is invoked by a pg_cron job every minute. It requires authentication to ensure only authorized cron workers can trigger FCM deliveries.

## Authentication Mechanism

### JWT-Based Authentication

The Edge Function (`supabase/functions/fcm-delivery/index.ts`) verifies JWTs using Supabase's JWKS (JSON Web Key Set). The JWT must:

1. **Be issued by Supabase Auth**: `issuer = '{SUPABASE_URL}/auth/v1'`
2. **Have role claim**: `role = 'service_role'`
3. **Be signed by Supabase's private key** (verified via JWKS)

### Using the Supabase Service Role Key

The Supabase **service_role key** (from Dashboard → Settings → API) is already a valid JWT that:
- Has `role = 'service_role'`
- Is signed by Supabase's private key
- Is verifiable via Supabase's JWKS

The Edge Function accepts the service_role key's default audience (typically `authenticated` or project reference).

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

The service_role key from Supabase Dashboard is used directly as the JWT.

**Option A: Via Supabase Dashboard SQL Editor**
```sql
SELECT vault.create_secret('fcm_worker_jwt', '<your-service-role-key>');
```

**Option B: Via Supabase CLI (requires linked project)**
```bash
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
supabase db exec "SELECT vault.create_secret('fcm_worker_jwt', '<your-service-role-key>');"
```

### 4. Deploy Edge Function

```bash
supabase functions deploy fcm-delivery
```

### 4. Set Edge Function Secrets

In Supabase Dashboard → Edge Functions → `fcm-delivery` → Settings → Secrets:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL` (from Firebase service account)
- `FIREBASE_PRIVATE_KEY` (from Firebase service account, PKCS#8 format)

### 5. Enable Cron Jobs

Run the following SQL in Supabase Dashboard → SQL Editor:

```sql
-- 1. Process scheduled notifications (every minute)
SELECT cron.schedule(
    'process-scheduled-notifications',
    '* * * * *',
    $$ SELECT public.process_scheduled_notifications(100); $$
);

-- 2. Process FCM delivery via Edge Function (every minute)
SELECT cron.schedule(
    'process-fcm-delivery',
    '* * * * *',
    $$
    SELECT net.http_post(
        url := 'https://<project-ref>.supabase.co/functions/v1/fcm-delivery',
        headers := public.get_fcm_worker_auth_header(),
        body := '{}'::jsonb
    ) AS response;
    $$
);

-- 3. Cleanup old processed deliveries (daily at 3 AM)
SELECT cron.schedule(
    'cleanup-notification-delivery-queue',
    '0 3 * * *',
    $$
    DELETE FROM public.notification_delivery_queue
    WHERE status IN ('sent', 'dead')
      AND updated_at < NOW() - INTERVAL '7 days';
    $$
);

-- 4. Cleanup old scheduled notifications (daily at 4 AM)
SELECT cron.schedule(
    'cleanup-scheduled-notifications',
    '0 4 * * *',
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
  -H "Authorization: Bearer <your-service-role-key>" \
  -H "Content-Type: application/json" \
  https://<project-ref>.supabase.co/functions/v1/fcm-delivery
```

Expected response: `{"processed":0,"message":"No pending deliveries"}` (if queue is empty)

## Security Notes

- **Never hardcode** the service_role key in migrations or code
- The JWT is stored in **Supabase Vault** (encrypted at rest)
- Only the `service_role` can read the Vault secret (via `SECURITY DEFINER` functions)
- The Edge Function validates every request using Supabase's JWKS
- The service_role key is never exposed to the client or cron job directly (retrieved via SECURITY DEFINER function)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "FCM worker JWT not configured in Vault" | Run the Vault secret creation SQL |
| "Unauthorized: invalid or missing worker JWT" | Check Authorization header format: `Bearer <service_role_key>` |
| "FCM credentials not configured" | Set Firebase secrets in Edge Function settings |
| Cron job not running | Check `pg_cron` and `pg_net` extensions are enabled |
| Edge Function returns 500 | Check Edge Function logs: `supabase functions logs fcm-delivery` |

## Files

- `supabase/migrations/20261109000001_phase5_fcm_worker_auth.sql` — Vault helper functions
- `supabase/migrations/20261108000017_phase5_scheduled_jobs.sql` — Cron job definitions
- `supabase/functions/fcm-delivery/index.ts` — Edge Function
- `supabase/scripts/store_fcm_worker_jwt.ts` — Helper script to store JWT in Vault