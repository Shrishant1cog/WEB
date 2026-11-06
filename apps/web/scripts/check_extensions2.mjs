import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

// Check pgcrypto extension
const { data: ext, error: extError } = await admin
  .from('pg_catalog.pg_extension')
  .select('extname')
  .eq('extname', 'pgcrypto');

console.log("pgcrypto extension:", ext, extError);