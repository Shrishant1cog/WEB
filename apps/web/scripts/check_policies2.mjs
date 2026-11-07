import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

async function check() {
  // Check match_entries policies
  const { data: mePol, error: meErr } = await admin.rpc('exec_sql', { 
    sql: "SELECT policyname, tablename, cmd, qual FROM pg_policies WHERE tablename = 'match_entries'" 
  });
  console.log('match_entries policies:', mePol, meErr);
  
  // Check team_members policies
  const { data: tmPol, error: tmErr } = await admin.rpc('exec_sql', { 
    sql: "SELECT policyname, tablename, cmd, qual FROM pg_policies WHERE tablename = 'team_members'" 
  });
  console.log('team_members policies:', tmPol, tmErr);
  
  // Check teams policies
  const { data: tPol, error: tErr } = await admin.rpc('exec_sql', { 
    sql: "SELECT policyname, tablename, cmd, qual FROM pg_policies WHERE tablename = 'teams'" 
  });
  console.log('teams policies:', tPol, tErr);
}

check();