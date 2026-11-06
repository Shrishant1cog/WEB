import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

// Check if functions exist in pg_proc
const { data, error } = await admin.rpc('exec_sql', { 
  sql: "SELECT proname, pg_get_function_arguments(oid) as args FROM pg_proc WHERE proname IN ('submit_dispute', 'start_match', 'complete_match', 'save_result_draft', 'publish_provisional_results')" 
});

console.log("Functions:", data, error);

// Check match table status after start_match
const { data: matches, error: matchError } = await admin
  .from('matches')
  .select('id, status, started_at, ended_at')
  .order('created_at', { ascending: false })
  .limit(5);

console.log("Recent matches:", matches, matchError);

// Check results table constraints
const { data: constraints, error: constError } = await admin.rpc('exec_sql', {
  sql: "SELECT conname, contype, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'public.results'::regclass"
});
console.log("Results constraints:", constraints, constError);

// Check match_entries table
const { data: entries, error: entriesError } = await admin
  .from('match_entries')
  .select('*');
console.log("Match entries:", entries, entriesError);