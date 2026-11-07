import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !anonKey || !serviceKey) {
  console.error("Missing SUPABASE_URL/SUPABASE_ANON_KEY/SUPABASE_SERVICE_ROLE_KEY.");
  process.exit(2);
}

const admin = createClient(url, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

async function test() {
  const run = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
  const password = `TestPass123!${run}`;

  async function makeUser(label) {
    const email = `${label}.${run}@example.com`;
    const { data, error } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { display_name: `${label} ${run}` },
    });
    if (error) throw new Error(`createUser ${label}: ${error.message}`);
    return { email, id: data.user.id };
  }

  function clientFor() {
    return createClient(url, anonKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }

  async function signIn(user) {
    const client = clientFor();
    const { error } = await client.auth.signInWithPassword({
      email: user.email,
      password,
    });
    if (error) throw new Error(`signIn ${user.email}: ${error.message}`);
    return client;
  }

  function tournamentPayload(overrides = {}) {
    const now = Date.now();
    const iso = (offset) => new Date(now + offset).toISOString();
    return {
      title: `Phase4 Test ${run}`,
      description: "Automated Phase 4 verification",
      format: "solo",
      mode: "br",
      max_teams: 4,
      team_size: 1,
      registration_starts_at: iso(-60 * 60 * 1000),
      registration_ends_at: iso(60 * 60 * 1000),
      tournament_starts_at: iso(2 * 60 * 60 * 1000),
      visibility: "public",
      waitlist_enabled: true,
      eligibility: { requires_ingame_id: false },
      ...overrides,
    };
  }

  async function createOpenTournament(client, overrides = {}) {
    const payload = tournamentPayload(overrides);
    const { data: id, error } = await client.rpc("create_tournament", { p_payload: payload });
    if (error) throw new Error(`create_tournament: ${error.message}`);
    for (const status of ["published", "registration_open"]) {
      const { error: statusError } = await client.rpc("set_tournament_status", {
        p_tournament_id: id,
        p_status: status,
      });
      if (statusError) throw new Error(`set_tournament_status(${status}): ${statusError.message}`);
    }
    return id;
  }

  // Create test users
  const organizer = await makeUser("organizer");
  const player = await makeUser("player");

  const organizerClient = await signIn(organizer);
  const playerClient = await signIn(player);

  // Create tournament
  const tournamentId = await createOpenTournament(organizerClient);
  console.log("Created tournament:", tournamentId);

  // Create match
  const { data: matchId, error: matchError } = await organizerClient.rpc("create_match", {
    p_tournament_id: tournamentId,
    p_round_name: "Round 1",
    p_match_number: 1,
    p_mode: "br",
    p_max_entries: 4,
    p_scheduled_at: new Date(Date.now() + 3600000).toISOString(),
  });
  if (matchError) throw new Error(`create_match: ${matchError.message}`);
  console.log("Created match:", matchId);

  // Register player
  const { data: entry, error: entryError } = await playerClient.rpc("register_tournament_entry", { p_tournament_id: tournamentId });
  if (entryError) throw new Error(`register_tournament_entry: ${entryError.message}`);
  console.log("Registered:", entry);

  // Assign entry to match
  const { error: assignError } = await organizerClient.rpc("assign_match_entries", {
    p_match_id: matchId,
    p_registration_ids: [entry.entry_id],
  });
  if (assignError) throw new Error(`assign_match_entries: ${assignError.message}`);
  console.log("Assigned entry to match");

  // Check match_entries
  const { data: entries, error: entriesError } = await organizerClient.from("match_entries").select("*");
  console.log("match_entries:", entries, entriesError?.message);

  // Test set_match_credentials
  const { error: credError } = await organizerClient.rpc("set_match_credentials", {
    p_match_id: matchId,
    p_room_id: "ROOM123",
    p_room_password: "password123",
    p_release_at: new Date(Date.now() + 60000).toISOString(),
  });
  console.log("set_match_credentials:", credError?.message || "OK");

  // Test get_match_credentials before release
  const { data: creds, error: credsError } = await playerClient.rpc("get_match_credentials", { p_match_id: matchId });
  console.log("get_match_credentials (before release):", creds, credsError?.message);

  // Wait for release
  console.log("Waiting for credential release...");
  await new Promise(r => setTimeout(r, 65000));

  // Test get_match_credentials after release
  const { data: creds2, error: creds2Error } = await playerClient.rpc("get_match_credentials", { p_match_id: matchId });
  console.log("get_match_credentials (after release):", creds2, creds2Error?.message);

  // Test results
  const { error: draftError } = await organizerClient.rpc("save_result_draft", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_rank: 1,
    p_kills: 5,
    p_placement_points: 10,
    p_kill_points: 5,
    p_total_points: 15,
    p_scoring_snapshot: { placement_points: { 1: 10 }, kill_points: 1, scoring_mode: "auto" },
  });
  console.log("save_result_draft:", draftError?.message || "OK");

  const { error: pubError } = await organizerClient.rpc("publish_provisional_results", { p_match_id: matchId });
  console.log("publish_provisional_results:", pubError?.message || "OK");

  // Test disputes
  const { data: disputeId, error: disputeError } = await playerClient.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Test dispute",
    p_evidence_paths: ["evidence/test.png"],
  });
  console.log("submit_dispute:", disputeId, disputeError?.message);

  console.log("All Phase 4 RPC tests completed!");
}

async function makeUser(label) {
  const run = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
  const email = `${label}.${run}@example.com`;
  const password = `TestPass123!${run}`;
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { display_name: `${label} ${run}` },
  });
  if (error) throw new Error(`createUser ${label}: ${error.message}`);
  return { email, id: data.user.id, password };
}

async function signIn(user) {
  const client = createClient(url, anonKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const { error } = await client.auth.signInWithPassword({ email: user.email, password: user.password });
  if (error) throw new Error(`signIn ${user.email}: ${error.message}`);
  return client;
}

test().catch((error) => {
  console.error(`FATAL ${error.stack ?? error}`);
  process.exit(1);
});