#!/usr/bin/env deno run --allow-env

/**
 * FCM Worker JWT Generation Guide
 *
 * This script explains the JWT generation approach for FCM worker authentication.
 *
 * The Supabase service_role key (from Dashboard > Settings > API) IS a valid JWT with:
 *   - role: 'service_role'
 *   - iss: '{SUPABASE_URL}/auth/v1'
 *   - aud: typically 'authenticated' or project ref
 *   - role: 'service_role'
 *   - exp: far future (10+ years)
 *
 * The Edge Function accepts the service_role key's default audience.
 * We store the service_role key directly in Vault as 'fcm_worker_jwt'.
 *
 * Usage:
 *   deno run --allow-env supabase/scripts/generate_fcm_worker_jwt.ts
 *
 * This script outputs the service_role key for manual storage in Vault.
 */

async function generateJWT() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set");
    console.error("Run: export SUPABASE_URL=... && export SUPABASE_SERVICE_ROLE_KEY=...");
    Deno.exit(1);
  }

  console.log("================================================================");
  console.log("FCM Worker JWT = Supabase service_role key");
  console.log("================================================================");
  console.log("");
  console.log("The Supabase service_role key IS a valid JWT with:");
  console.log("  - role: 'service_role'");
  console.log("  - iss: '{SUPABASE_URL}/auth/v1'");
  console.log("  - aud: typically 'authenticated' or project ref");
  console.log("  - role: 'service_role'");
  console.log("  - exp: far future (10+ years)");
  console.log("");
  console.log("The Edge Function accepts the service_role key's default audience.");
  console.log("We store the service_role key directly in Vault as 'fcm_worker_jwt'.");
  console.log("");
  console.log("================================================================");
  console.log("DEPLOYMENT STEPS:");
  console.log("================================================================");
  console.log("");
  console.log("1. Get your service_role key from Supabase Dashboard:");
  console.log("   Dashboard > Settings > API > service_role key");
  console.log("");
  console.log("2. Store it in Supabase Vault:");
  console.log("   Run this SQL in Supabase Dashboard SQL Editor:");
  console.log("   SELECT vault.create_secret('fcm_worker_jwt', '<your-service-role-key>');");
  console.log("");
  console.log("3. Or use the helper script:");
  console.log("   deno run --allow-env --allow-run supabase/scripts/store_fcm_worker_jwt.ts");
  console.log("");
  console.log("4. Enable required extensions in Supabase Dashboard:");
  console.log("   - pg_cron");
  console.log("   - pg_net");
  console.log("");
  console.log("5. Deploy the Edge Function:");
  console.log("   supabase functions deploy fcm-delivery");
  console.log("");
  console.log("6. Set Edge Function secrets (Dashboard > Edge Functions > fcm-delivery > Settings):");
  console.log("   - FIREBASE_PROJECT_ID");
  console.log("   - FIREBASE_CLIENT_EMAIL");
  console.log("   - FIREBASE_PRIVATE_KEY");
  console.log("");
  console.log("6. Enable cron jobs (run in SQL Editor):");
  console.log("   -- Scheduled notifications processor");
  console.log("   SELECT cron.schedule(");
  console.log("       'process-scheduled-notifications',");
  console.log("       '* * * * *',");
  console.log("       $$ SELECT public.process_scheduled_notifications(100); $$");
  console.log("   );");
  console.log("");
  console.log("   -- FCM delivery processor");
  console.log("   SELECT cron.schedule(");
  console.log("       'process-fcm-delivery',");
  console.log("       '* * * * *',");
  console.log("       $$");
  console.log("       SELECT net.http_post(");
  console.log("           url := 'https://<project-ref>.supabase.co/functions/v1/fcm-delivery',");
  console.log("           headers := public.get_fcm_worker_auth_header(),");
  console.log("           body := '{}'::jsonb");
  console.log("       ) AS response;");
  console.log("       $$");
  console.log("   );");
  console.log("");
  console.log("   -- Cleanup jobs");
  console.log("   SELECT cron.schedule(");
  console.log("       'cleanup-notification-delivery-queue',");
  console.log("       '0 3 * * *',");
  console.log("       $$ DELETE FROM public.notification_delivery_queue WHERE status IN ('sent', 'dead') AND updated_at < NOW() - INTERVAL '7 days'; $$");
  console.log("   );");
  console.log("   SELECT cron.schedule(");
  console.log("       'cleanup-scheduled-notifications',");
  console.log("       '0 4 * * *',");
  console.log("       $$ DELETE FROM public.scheduled_notifications WHERE processed_at IS NOT NULL AND processed_at < NOW() - INTERVAL '30 days'; $$");
  console.log("   );");
  console.log("");
  console.log("================================================================");
  console.log("Your service_role key (use this as the JWT):");
  console.log("================================================================");
  console.log(Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "<not set in environment>");
}

generateJWT().catch(console.error);