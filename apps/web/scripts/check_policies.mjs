import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

async function check() {
  const { data, error } = await admin.from('match_entries').select('*');
  console.log('match_entries (service role):', data, error);
  
  const { data: teams, error: teamsError } = await admin.from('team_members').select('*').limit(1);
  console.log('team_members (service role):', teams, teamsError);
  
  const { data: policies, error: policiesError } = await admin
    .from('pg_policies')
    .select('policyname, tablename, cmd')
    .in('tablename', ['match_entries', 'team_members', 'teams']);
  console.log('policies:', policies, policiesError);
}

check();