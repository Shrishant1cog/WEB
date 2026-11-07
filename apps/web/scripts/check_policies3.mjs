import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

async function check() {
  // Query pg_policies directly
  const { data, error } = await admin
    .from('pg_catalog.pg_policies')
    .select('policyname, tablename, cmd, qual')
    .in('tablename', ['match_entries', 'team_members', 'teams']);
  console.log('policies:', data, error);
}

check();