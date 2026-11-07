import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

async function check() {
  // Create a temporary function to query pg_policies
  const { error: createErr } = await admin.rpc('exec_sql', { 
    sql: `
      CREATE OR REPLACE FUNCTION public.get_policies() 
      RETURNS TABLE(policyname text, tablename text, cmd text, qual text) 
      LANGUAGE sql STABLE SECURITY DEFINER 
      AS $$
        SELECT policyname, tablename, cmd, qual 
        FROM pg_catalog.pg_policies 
        WHERE tablename IN ('match_entries', 'team_members', 'teams');
      $$;
    ` 
  });
  if (createErr) { console.log('Create function error:', createErr.message); return; }
  
  // Call the function
  const { data, error } = await admin.rpc('get_policies');
  console.log('policies:', data, error);
  
  // Clean up
  await admin.rpc('exec_sql', { sql: 'DROP FUNCTION public.get_policies()' });
}

check();