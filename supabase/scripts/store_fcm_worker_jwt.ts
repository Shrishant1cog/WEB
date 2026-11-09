#!/usr/bin/env deno run --allow-env

/**
 * Store FCM Worker JWT in Supabase Vault
 *
 * The Supabase service_role key (from Dashboard) IS a valid JWT with:
 *   - role: 'service_role'
 *   - iss: '{SUPABASE_URL}/auth/v1'
 *   - aud: typically 'authenticated' or project ref
 *
 * The Edge Function now accepts the service_role key's default audience.
 * We store the service_role key directly in Vault as 'fcm_worker_jwt'.
 *
 * Usage:
 *   deno run --allow-env supabase/scripts/store_fcm_worker_jwt.ts
 *
 * Prerequisites:
 *   - SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in environment
 *   - Supabase CLI linked to project: supabase link --project-ref <ref>
 */

async function storeJWT() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set");
    console.error("Run: export SUPABASE_URL=... && export SUPABASE_SERVICE_ROLE_KEY=...");
    Deno.exit(1);
  }

  console.log("Storing service_role key as fcm_worker_jwt in Vault...");

  // Use Supabase CLI to call the vault.create_secret function
  // This requires the Supabase CLI to be linked to the project
  const cmd = [
    "supabase",
    "db",
    "exec",
    "--project-ref", // will be auto-detected if linked
    `SELECT vault.create_secret('fcm_worker_jwt', '${serviceRoleKey.replace(/'/g, "''")}');`
  ];

  const proc = new Deno.Command("supabase", {
    args: ["db", "exec", `SELECT vault.create_secret('fcm_worker_jwt', '${serviceRoleKey.replace(/'/g, "''")}');`],
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await proc.output();

  if (code !== 0) {
    console.error("Error storing JWT in Vault:");
    console.error(new TextDecoder().decode(stderr));
    console.log("\nAlternative: Run this SQL manually in Supabase Dashboard SQL Editor:");
    console.log(`SELECT vault.create_secret('fcm_worker_jwt', '<service_role_key>');`);
    Deno.exit(1);
  }

  console.log("Success! JWT stored in Vault as 'fcm_worker_jwt'");
  console.log(new TextDecoder().decode(stdout));
}

storeJWT().catch(console.error);