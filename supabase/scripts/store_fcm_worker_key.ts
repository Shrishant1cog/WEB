#!/usr/bin/env deno run --allow-env --allow-run

/**
 * Store FCM Worker API Key in Supabase Vault
 *
 * The Supabase service_role key (from Dashboard) is an opaque API key.
 * We store it directly in Vault as 'fcm_worker_key'.
 *
 * Usage:
 *   deno run --allow-env --allow-run supabase/scripts/store_fcm_worker_key.ts
 *
 * Prerequisites:
 *   - SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in environment
 *   - Supabase CLI linked to project: supabase link --project-ref <ref>
 */

async function storeKey() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set");
    console.error("Run: export SUPABASE_URL=... && export SUPABASE_SERVICE_ROLE_KEY=...");
    Deno.exit(1);
  }

  console.log("Storing service_role key as fcm_worker_key in Vault...");

  // Use Supabase CLI to call the vault.create_secret function
  const sql = `SELECT vault.create_secret('fcm_worker_key', '${serviceRoleKey.replace(/'/g, "''")}');`;
  
  const proc = new Deno.Command("supabase", {
    args: ["db", "exec", sql],
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await proc.output();

  if (code !== 0) {
    console.error("Error storing key in Vault:");
    console.error(new TextDecoder().decode(stderr));
    console.log("\nAlternative: Run this SQL manually in Supabase Dashboard SQL Editor:");
    console.log(`SELECT vault.create_secret('fcm_worker_key', '<service_role_key>');`);
    Deno.exit(1);
  }

  console.log("Success! API key stored in Vault as 'fcm_worker_key'");
  // Do not log the secret
}

storeKey().catch(console.error);