import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !serviceKey) {
  console.error("Missing SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY.");
  process.exit(2);
}

const admin = createClient(url, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// Get all tables
const { data: tables, error: tablesError } = await admin
  .from("information_schema.tables")
  .select("table_name")
  .eq("table_schema", "public")
  .order("table_name");

if (tablesError) {
  console.error("Error fetching tables:", tablesError);
  process.exit(1);
}

console.log("=== PUBLIC TABLES ===");
tables.forEach(t => console.log(t.table_name));

// Get matches table structure if it exists
const { data: matchesCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "matches")
  .order("ordinal_position");

if (matchesCols && matchesCols.length > 0) {
  console.log("\n=== MATCHES TABLE COLUMNS ===");
  matchesCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Get results table structure if it exists
const { data: resultsCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "results")
  .order("ordinal_position");

if (resultsCols && resultsCols.length > 0) {
  console.log("\n=== RESULTS TABLE COLUMNS ===");
  resultsCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check for match_room_secrets
const { data: roomCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "match_room_secrets")
  .order("ordinal_position");

if (roomCols && roomCols.length > 0) {
  console.log("\n=== MATCH_ROOM_SECRETS TABLE COLUMNS ===");
  roomCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check for disputes
const { data: disputesCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "disputes")
  .order("ordinal_position");

if (disputesCols && disputesCols.length > 0) {
  console.log("\n=== DISPUTES TABLE COLUMNS ===");
  disputesCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check for tournament_results
const { data: tResultsCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "tournament_results")
  .order("ordinal_position");

if (tResultsCols && tResultsCols.length > 0) {
  console.log("\n=== TOURNAMENT_RESULTS TABLE COLUMNS ===");
  tResultsCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check for match_entries
const { data: mEntriesCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "match_entries")
  .order("ordinal_position");

if (mEntriesCols && mEntriesCols.length > 0) {
  console.log("\n=== MATCH_ENTRIES TABLE COLUMNS ===");
  mEntriesCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check tournament_registrations
const { data: tRegCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "tournament_registrations")
  .order("ordinal_position");

if (tRegCols && tRegCols.length > 0) {
  console.log("\n=== TOURNAMENT_REGISTRATIONS TABLE COLUMNS ===");
  tRegCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check tournament_entry_members
const { data: tEMCols } = await admin
  .from("information_schema.columns")
  .select("column_name, data_type, is_nullable, column_default")
  .eq("table_schema", "public")
  .eq("table_name", "tournament_entry_members")
  .order("ordinal_position");

if (tEMCols && tEMCols.length > 0) {
  console.log("\n=== TOURNAMENT_ENTRY_MEMBERS TABLE COLUMNS ===");
  tEMCols.forEach(c => console.log(`${c.column_name} | ${c.data_type} | nullable: ${c.is_nullable} | default: ${c.column_default}`));
}

// Check policies on matches if exists
const { data: policies } = await admin
  .from("pg_policies")
  .select("schemaname, tablename, policyname, cmd, qual, with_check")
  .in("tablename", ["matches", "results", "match_room_secrets", "disputes", "tournament_results", "match_entries", "tournament_registrations", "tournament_entry_members", "tournament_organizers"]);

if (policies && policies.length > 0) {
  console.log("\n=== RLS POLICIES ===");
  policies.forEach(p => {
    console.log(`${p.tablename} | ${p.policyname} | ${p.cmd}`);
  });
}