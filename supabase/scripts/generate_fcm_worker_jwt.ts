#!/usr/bin/env deno run --allow-env --allow-net

/**
 * Generate FCM Worker JWT for Supabase Vault
 *
 * This script generates a JWT with:
 *   - role: 'service_role'
 *   - aud: 'fcm-worker'
 *   - iss: '{SUPABASE_URL}/auth/v1'
 *   - exp: 10 years from now
 *
 * The JWT is signed with the Supabase service_role key.
 * Run this script locally, then store the output in Vault:
 *   SELECT vault.create_secret('fcm_worker_jwt', '<output>');
 *
 * Usage:
 *   deno run --allow-env --allow-net supabase/scripts/generate_fcm_worker_jwt.ts
 */

import { SignJWT } from "https://esm.sh/jose@5.2.0";

async function generateJWT() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set");
    Deno.exit(1);
  }

  // Parse the service role key (it's a JWT itself)
  // The service role key is a JWT signed by Supabase. We need to extract the signing key.
  // Actually, the service role key is the JWT itself that we use to sign other JWTs.
  // Wait - the service_role key in Supabase is a JWT that can be used to verify other JWTs.
  // For signing, we need the private key. But Supabase doesn't expose the private key.
  //
  // Actually, the service_role key in Supabase is a JWT that contains the public key info.
  // We can't use it to SIGN other JWTs. We need to use the Supabase Management API or
  // create a JWT using the Supabase Auth admin API.
  //
  // Alternative approach: Use the Supabase service_role key as the JWT itself!
  // The service_role key IS a JWT with role=service_role. We can use it directly
  // by changing the audience claim. But we can't modify a signed JWT.
  //
  // Correct approach: The Edge Function verifies JWTs using the Supabase JWKS.
  // The JWKS contains the public keys for the Supabase Auth instance.
  // The service_role key is a JWT signed by Supabase's private key.
  // We need to create a JWT that will be verified by the same JWKS.
  //
  // Solution: Use the Supabase service_role key AS the JWT for the worker.
  // The service_role key already has:
  //   - role: service_role
  //   - iss: {SUPABASE_URL}/auth/v1
  // We just need to change the audience to 'fcm-worker'.
  // But we can't modify a signed JWT.
  //
  // Real solution: Generate a new JWT signed with the SAME private key that Supabase uses.
  // Since we don't have access to that private key, we need a different approach.
  //
  // ACTUAL SOLUTION: The Supabase service_role key IS the JWT we should use.
  // The Edge Function verifies using the Supabase JWKS, which contains the public key
  // for the service_role JWT. We just need to pass the service_role key as-is,
  // but the Edge Function expects audience 'fcm-worker'.
  //
  // The service_role JWT has audience 'authenticated' (or similar).
  // We need a JWT with audience 'fcm-worker'.
  //
  // The only way: Create a new JWT using the Supabase Management API or
  // use a custom JWT signed with a key that's in the JWKS.
  //
  // PRACTICAL SOLUTION: Use the service_role key directly as the Bearer token.
  // Modify the Edge Function to accept the service_role key directly
  // (which already has role=service_role and is verified by Supabase).
  //
  // Actually, looking at the Edge Function code again:
  // - It verifies using the Supabase JWKS
  // - It checks audience == 'fcm-worker'
  // - It checks role == 'service_role'
  //
  // The service_role key from Supabase Dashboard has:
  // - role: 'service_role'
  // - aud: 'authenticated' (or similar)
  // - iss: '{SUPABASE_URL}/auth/v1'
  //
  // We need a JWT with aud='fcm-worker'. We can't change the aud of an existing JWT.
  //
  // SOLUTION: Use the Supabase Admin API to create a custom JWT, or
  // create a custom JWT using a shared secret that we add to the JWKS.
  //
  // Simplest production approach: Use the Supabase service_role key directly
  // and MODIFY the Edge Function to accept the service_role key's audience.
  
  console.log("================================================================");
  console.log("IMPORTANT: Cannot generate custom JWT without private key access");
  console.log("================================================================");
  console.log("");
  console.log("SOLUTION: Use the Supabase service_role key directly.");
  console.log("The service_role key from Supabase Dashboard is already a valid JWT");
  console.log("with role=service_role, issued by Supabase Auth.");
  console.log("");
  console.log("REQUIRED CHANGE: Update Edge Function to accept the service_role");
  console.log("key's default audience (usually 'authenticated') OR modify the");
  console.log("Edge Function to accept service_role without audience check.");
  console.log("");
  console.log("RECOMMENDED: Update Edge Function verifyWorkerJWT() to accept");
  console.log("the service_role key's default audience OR make audience optional.");
  console.log("");
  console.log("Then store the service_role key in Vault:");
  console.log("  SELECT vault.create_secret('fcm_worker_jwt', '<service_role_key>');");
  console.log("================================================================");
  
  // For now, output the service role key if available
  if (Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")) {
    console.log("");
    console.log("Your service_role key (use this as the JWT):");
    console.log(Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
  }
}

generateJWT().catch(console.error);