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

let passed = 0;
let failed = 0;

function check(name, condition, detail = "") {
  if (condition) {
    passed += 1;
    console.log(`PASS ${name}`);
  } else {
    failed += 1;
    console.log(`FAIL ${name}${detail ? ` :: ${detail}` : ""}`);
  }
}

async function expectFailure(name, promise, key) {
  const { error } = await promise;
  check(
    name,
    Boolean(error) && String(error.message).includes(key),
    error ? error.message : "expected an error"
  );
}

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
  return { email, id: data.user.id, password };
}

function clientFor() {
  return createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

async function signIn(user) {
  const client = createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { error } = await client.auth.signInWithPassword({
    email: user.email,
    password: user.password,
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
    registration_starts_at: new Date(now - 60 * 60 * 1000).toISOString(),
    registration_ends_at: new Date(now + 60 * 60 * 1000).toISOString(),
    tournament_starts_at: new Date(now + 2 * 60 * 60 * 1000).toISOString(),
    visibility: "public",
    waitlist_enabled: true,
    eligibility: { requires_ingame_id: false },
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

async function testMatchLifecycle() {
  console.log("=== Testing Match Lifecycle ===");

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
  check("create_match succeeds", !matchError && Boolean(matchId), matchError?.message);

  // Register player
  const { data: entry, error: entryError } = await playerClient.rpc("register_tournament_entry", { p_tournament_id: tournamentId });
  check("player registration succeeds", !entryError && Boolean(entry?.entry_id), entryError?.message);

  // Assign entry to match
  const { error: assignError } = await organizerClient.rpc("assign_match_entries", {
    p_match_id: matchId,
    p_registration_ids: [entry.entry_id],
  });
  check("assign_match_entries succeeds", !assignError, assignError?.message);

  // Check match_entries
  const { data: entries, error: entriesError } = await organizerClient.from("match_entries").select("*");
  check("match_entries query works", !entriesError, entriesError?.message);
  check("entry assigned correctly", entries?.length === 1 && entries[0].registration_id === entry.entry_id);

  // Test set_match_credentials
  const { error: credError } = await organizerClient.rpc("set_match_credentials", {
    p_match_id: matchId,
    p_room_id: "ROOM123",
    p_room_password: "password123",
    p_release_at: new Date(Date.now() + 60000).toISOString(),
  });
  check("set_match_credentials succeeds", !credError, credError?.message);

  // Test get_match_credentials before release (should fail)
  const { data: credsBefore, error: credsBeforeError } = await playerClient.rpc("get_match_credentials", { p_match_id: matchId });
  check("get_match_credentials before release fails", !!credsBeforeError && credsBeforeError.message.includes("CREDENTIALS_NOT_RELEASED"));

  // Start match
  const { error: startError } = await organizerClient.rpc("start_match", { p_match_id: matchId });
  check("start_match succeeds", !startError, startError?.message);

  // Complete match
  const { error: completeError } = await organizerClient.rpc("complete_match", { p_match_id: matchId });
  check("complete_match succeeds", !completeError, completeError?.message);

  // Wait for credential release
  console.log("Waiting for credential release...");
  await new Promise(r => setTimeout(r, 65000));

  // Test get_match_credentials after release
  const { data: credsAfter, error: credsAfterError } = await playerClient.rpc("get_match_credentials", { p_match_id: matchId });
  check("get_match_credentials after release succeeds", !credsAfterError && credsAfter?.room_id && credsAfter?.room_password, credsAfterError?.message);

  // Test credentials for outsider (should fail)
  const outsider = await makeUser("outsider");
  const outsiderClient = await signIn(outsider);
  const { error: outsiderCredError } = await outsiderClient.rpc("get_match_credentials", { p_match_id: matchId });
  check("outsider cannot access credentials", !!outsiderCredError && outsiderCredError.message.includes("ENTRY_NOT_ASSIGNED"));

  // Test save_result_draft
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
  check("save_result_draft succeeds", !draftError, draftError?.message);

  // Test duplicate draft rejected
  const { error: dupDraftError } = await organizerClient.rpc("save_result_draft", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_rank: 2,
    p_kills: 3,
    p_placement_points: 5,
    p_kill_points: 3,
    p_total_points: 8,
    p_scoring_snapshot: {},
  });
  check("duplicate draft rejected", !!dupDraftError && dupDraftError.message.includes("RESULT_DRAFT_EXISTS"));

  // Test publish_provisional_results
  const { error: pubError } = await organizerClient.rpc("publish_provisional_results", { p_match_id: matchId });
  check("publish_provisional_results succeeds", !pubError, pubError?.message);

  // Verify provisional result
  const { data: provResult } = await playerClient
    .from("results")
    .select("status, rank, total_points")
    .eq("match_id", matchId)
    .eq("registration_id", entry.entry_id)
    .single();
  check("result status provisional", provResult?.status === "provisional" && provResult?.rank === 1);

  // Test dispute submission
  const { data: disputeId, error: disputeError } = await playerClient.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Test dispute",
    p_evidence_paths: ["evidence/test.png"],
  });
  check("submit_dispute succeeds", !disputeError && Boolean(disputeId), disputeError?.message);

  // Test duplicate dispute rejected
  await expectFailure("duplicate dispute rejected", playerClient.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Another reason",
    p_evidence_paths: [],
  }), "DISPUTE_ALREADY_EXISTS");

  // Test dispute by outsider (should fail)
  const outsider2 = await makeUser("outsider2");
  const outsider2Client = await signIn(outsider2);
  await expectFailure("outsider cannot submit dispute", outsider2Client.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Test",
    p_evidence_paths: [],
  }), "ENTRY_NOT_ASSIGNED");

  console.log("All Phase 4 RPC tests completed!");
}

async function makeUser(label) {
  const email = `${label}.${run}@example.com`;
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { display_name: `${label} ${run}` },
  });
  if (error) throw new Error(`createUser ${label}: ${error.message}`);
  return { email, id: data.user.id, password };
}

function clientFor() {
  return createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

async function signIn(user) {
  const client = createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { error } = await client.auth.signInWithPassword({
    email: user.email,
    password: user.password,
  });
  if (error) throw new Error(`signIn ${user.email}: ${error.message}`);
  return client;
}

function tournamentPayload() {
  const now = Date.now();
  const iso = (offset) => new Date(now + offset).toISOString();
  return {
    title: `Phase4 Test ${run}`,
    description: "Automated Phase 4 verification",
    format: "solo",
    mode: "br",
    max_teams: 4,
    team_size: 1,
    registration_starts_at: new Date(now - 60 * 60 * 1000).toISOString(),
    registration_ends_at: new Date(now + 60 * 60 * 1000).toISOString(),
    tournament_starts_at: new Date(now + 2 * 60 * 60 * 1000).toISOString(),
    visibility: "public",
    waitlist_enabled: true,
    eligibility: { requires_ingame_id: false },
  };
}

async function createOpenTournament(client) {
  const payload = tournamentPayload();
  const { data: id, error } = await client.rpc("create_tournament", { p_payload: payload });
  if (error) throw new Error(`create_tournament: ${error.message}`);
  for (const status of ["published", "registration_open"]) {
    const { error: statusError } = await client.rpc("set_tournament_status", {
      p_tournament_id: id,
      p_status: status,
    });
    if (statusError) throw new Error(`set_tournament_status: ${statusError.message}`);
  }
  return id;
}

async function testMatchLifecycle() {
  console.log("=== Testing Match Lifecycle ===");

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
  check("create_match succeeds", !matchError && Boolean(matchId), matchError?.message);

  // Register player
  const { data: entry, error: entryError } = await playerClient.rpc("register_tournament_entry", { p_tournament_id: tournamentId });
  check("player registration succeeds", !entryError && Boolean(entry?.entry_id), entryError?.message);

  // Assign entry to match
  const { error: assignError } = await organizerClient.rpc("assign_match_entries", {
    p_match_id: matchId,
    p_registration_ids: [entry.entry_id],
  });
  check("assign_match_entries succeeds", !assignError, assignError?.message);

  // Check match_entries
  const { data: entries, error: entriesError } = await organizerClient.from("match_entries").select("*");
  check("match_entries query works", !entriesError, entriesError?.message);
  check("entry assigned correctly", entries?.length === 1 && entries[0].registration_id === entry.entry_id);

  // Test set_match_credentials
  const { error: credError } = await organizerClient.rpc("set_match_credentials", {
    p_match_id: matchId,
    p_room_id: "ROOM123",
    p_room_password: "password123",
    p_release_at: new Date(Date.now() + 60000).toISOString(),
  });
  check("set_match_credentials succeeds", !credError, credError?.message);

  // Test get_match_credentials before release (should fail)
  const { data: credsBefore, error: credsBeforeError } = await playerClient.rpc("get_match_credentials", { p_match_id: matchId });
  check("get_match_credentials before release fails", !!credsBeforeError && credsBeforeError.message.includes("CREDENTIALS_NOT_RELEASED"));

  // Start match
  const { error: startError } = await organizerClient.rpc("start_match", { p_match_id: matchId });
  check("start_match succeeds", !startError, startError?.message);

  // Complete match
  const { error: completeError } = await organizerClient.rpc("complete_match", { p_match_id: matchId });
  check("complete_match succeeds", !completeError, completeError?.message);

  // Wait for credential release
  console.log("Waiting for credential release...");
  await new Promise(r => setTimeout(r, 65000));

  // Test get_match_credentials after release
  const { data: credsAfter, error: credsAfterError } = await playerClient.rpc("get_match_credentials", { p_match_id: matchId });
  check("get_match_credentials after release succeeds", !credsAfterError && credsAfter?.room_id && credsAfter?.room_password, credsAfterError?.message);

  // Test credentials for outsider (should fail)
  const outsider = await makeUser("outsider");
  const outsiderClient = await signIn(outsider);
  const { error: outsiderCredError } = await outsiderClient.rpc("get_match_credentials", { p_match_id: matchId });
  check("outsider cannot access credentials", !!outsiderCredError && outsiderCredError.message.includes("ENTRY_NOT_ASSIGNED"));

  // Test save_result_draft
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
  check("save_result_draft succeeds", !draftError, draftError?.message);

  // Test duplicate draft rejected
  const { error: dupDraftError } = await organizerClient.rpc("save_result_draft", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_rank: 2,
    p_kills: 3,
    p_placement_points: 5,
    p_kill_points: 3,
    p_total_points: 8,
    p_scoring_snapshot: {},
  });
  check("duplicate draft rejected", !!dupDraftError && dupDraftError.message.includes("RESULT_DRAFT_EXISTS"));

  // Test publish_provisional_results
  const { error: pubError } = await organizerClient.rpc("publish_provisional_results", { p_match_id: matchId });
  check("publish_provisional_results succeeds", !pubError, pubError?.message);

  // Verify provisional result
  const { data: provResult } = await playerClient
    .from("results")
    .select("status, rank, total_points")
    .eq("match_id", matchId)
    .eq("registration_id", entry.entry_id)
    .single();
  check("result status provisional", provResult?.status === "provisional" && provResult?.rank === 1);

  // Test dispute submission
  const { data: disputeId, error: disputeError } = await playerClient.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Test dispute",
    p_evidence_paths: ["evidence/test.png"],
  });
  check("submit_dispute succeeds", !disputeError && Boolean(disputeId), disputeError?.message);

  // Test duplicate dispute rejected
  await expectFailure("duplicate dispute rejected", playerClient.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Another reason",
    p_evidence_paths: [],
  }), "DISPUTE_ALREADY_EXISTS");

  // Test dispute by outsider (should fail)
  const outsider2 = await makeUser("outsider2");
  const outsider2Client = await signIn(outsider2);
  await expectFailure("outsider cannot submit dispute", outsider2Client.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: entry.entry_id,
    p_reason: "Test",
    p_evidence_paths: [],
  }), "ENTRY_NOT_ASSIGNED");

  console.log("All Phase 4 RPC tests completed!");
}

const run = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
const password = `TestPass123!${run}`;

const admin = createClient(url, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

let passed = 0;
let failed = 0;

function check(name, condition, detail = "") {
  if (condition) {
    passed += 1;
    console.log(`PASS ${name}`);
  } else {
    failed += 1;
    console.log(`FAIL ${name}${detail ? ` :: ${detail}` : ""}`);
  }
}

async function expectFailure(name, promise, key) {
  const { error } = await promise;
  check(
    name,
    Boolean(error) && String(error.message).includes(key),
    error ? error.message : "expected an error"
  );
}

async function main() {
  await testMatchLifecycle();

  console.log(`\nPhase 4 tests: ${passed} passed, ${failed} failed.`);
  process.exit(failed === 0 ? 0 : 1);
}

main().catch((error) => {
  console.error(`FATAL ${error.stack ?? error}`);
  process.exit(1);
}