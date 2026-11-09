#!/usr/bin/env deno run --allow-env

/**
 * FCM Worker API Key Storage Guide
 *
 * The Supabase service_role key (from Dashboard > Settings > API) is an opaque API key.
 * We store it directly in Vault as 'fcm_worker_key'.
 *
 * Usage:
 *   deno run --allow-env supabase/scripts/generate_fcm_worker_key.ts
 *
 * This script outputs the deployment steps.
 */

async function guide() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set");
    console.error("Run: export SUPABASE_URL=... && export SUPABASE_SERVICE_ROLE_KEY=...");
    Deno.exit(1);
  }

  console.log("================================================================");
  console.log("FCM Worker API Key = Supabase service_role key");
  console.log("================================================================");
  console.log("");
  console.log("The Supabase service_role key is an opaque API key (not a JWT).");
  console.log("The Edge Function validates it by comparing against the Vault secret.");
  console.log("We store it directly in Vault as 'fcm_worker_key'.");
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
  console.log("   SELECT vault.create_secret('fcm_worker_key', '<your-service-role-key>');");
  console.log("");
  console.log("3. Or use the helper script:");
  console.log("   deno run --allow-env --allow-run supabase/scripts/store_fcm_worker_key.ts");
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
  console.log("7. Set FCM_WORKER_API_KEY in Edge Function secrets (Dashboard > Edge Functions > fcm-delivery > Settings):");
  console.log("   - FCM_WORKER_API_KEY = <your-service-role-key>");
  console.log("");
  console.log("7. Enable cron jobs (run in SQL Editor):");
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
  console.log("           headers := fcm_internal.get_fcm_worker_auth_header(),");
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
  console.log("Configuration complete. Do not print the service role key in logs.");
  console.log("================================================================");
}

guide().catch(console.error);