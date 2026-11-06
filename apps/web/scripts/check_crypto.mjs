import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

const { data, error } = await admin.rpc('exec_sql', { 
  sql: "SELECT proname FROM pg_proc WHERE proname LIKE 'pgp_%' OR proname LIKE 'encrypt%' OR proname LIKE 'decrypt%' OR proname LIKE 'crypt%' OR proname LIKE 'digest%' OR proname LIKE 'hmac%' OR proname LIKE 'hmac%' ORDER BY proname" 
});

console.log("Functions:", data, error);