import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

// Check pgcrypto extension
const { data: ext, error: extError } = await admin
  .from('pg_extension')
  .select('extname')
  .eq('extname', 'pgcrypto');

console.log("pgcrypto extension:", ext, extError);

// Check if pgp_sym_encrypt exists
const { data: proc, error: procError } = await admin.rpc('exec_sql', { 
  sql: "SELECT proname, oid FROM pg_proc WHERE proname = 'pgp_sym_encrypt'" 
});
console.log("pgp_sym_encrypt:", proc, procError);