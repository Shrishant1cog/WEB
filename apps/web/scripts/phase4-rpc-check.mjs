// Phase 4 database verification — match operations, credentials, results,
// disputes, team-staff authorization and match-capacity edge cases.
//
// Every assertion is one of:
//   PASS     behaviour was actually verified
//   FAIL     behaviour is incorrect
//   BLOCKED  infrastructure prevented the test (script exits non-zero)
//   SKIPPED  explicitly not run (never counted as PASS)
//
// Usage (local stack values come from `supabase status`):
//   node scripts/phase4-rpc-check.mjs
// with SUPABASE_URL, SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY set.

import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !anonKey || !serviceKey) {
  console.error("Missing SUPABASE_URL/SUPABASE_ANON_KEY/SUPABASE_SERVICE_ROLE_KEY.");
  process.exit(2);
}

const run = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
const password = `Phase4!${run}`;
let passed = 0;
let failed = 0;
let blocked = 0;

function check(name, condition, detail = "") {
  if (condition) {
    passed += 1;
    console.log(`PASS ${name}`);
  } else {
    failed += 1;
    console.log(`FAIL ${name}${detail ? ` :: ${detail}` : ""}`);
  }
}

function blockedTest(name, detail) {
  blocked += 1;
  console.log(`BLOCKED ${name}${detail ? ` :: ${detail}` : ""}`);
}

function errorText(error) {
  if (!error) return "";
  return `${error.message ?? ""} ${error.details ?? ""} ${error.hint ?? ""}`;
}

async function expectFailure(name, promise, key) {
  const result = await promise;
  const error = result?.error;
  check(
    name,
    Boolean(error) && errorText(error).includes(key),
    error ? errorText(error) : "expected an error but the call succeeded"
  );
  return result;
}

async function expectAnyFailure(name, promise, keys) {
  const result = await promise;
  const error = result?.error;
  const text = errorText(error);
  check(
    name,
    Boolean(error) && keys.some((key) => text.includes(key)),
    error ? text : "expected an error but the call succeeded"
  );
  return result;
}

const admin = createClient(url, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// -------------------------------------------------------- schema verification
// Instead of sleeping and hoping PostgREST reloaded, verify the exact RPCs are
// present in the live OpenAPI document. If they never appear, the run is
// BLOCKED (not PASS).
const requiredRpcs = [
  "assign_match_entries",
  "save_result_draft",
  "publish_provisional_results",
  "finalize_match_results",
  "submit_dispute",
  "assign_dispute_moderator",
  "is_team_staff",
];

async function fetchRpcPaths() {
  const response = await fetch(`${url}/rest/v1/`, {
    headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` },
  });
  if (!response.ok) {
    throw new Error(`OpenAPI request failed: ${response.status} ${response.statusText}`);
  }
  const spec = await response.json();
  return new Set(Object.keys(spec.paths ?? {}));
}

async function ensureRpcsVisible() {
  const deadline = Date.now() + 30000;
  let missing = requiredRpcs;
  while (Date.now() < deadline) {
    const paths = await fetchRpcPaths();
    missing = requiredRpcs.filter((name) => !paths.has(`/rpc/${name}`));
    if (missing.length === 0) {
      console.log(`PASS PostgREST exposes required RPCs (${requiredRpcs.length})`);
      passed += 1;
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
  blockedTest(
    "PostgREST schema cache exposes required RPCs",
    `missing: ${missing.join(", ")}`
  );
  throw new Error(`BLOCKED: PostgREST did not expose ${missing.join(", ")}`);
}

// -------------------------------------------------------- fixtures
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
    title: `Phase4 Cup ${run} ${Math.floor(Math.random() * 100000)}`,
    description: "Automated Phase 4 verification",
    format: "squad",
    mode: "br",
    max_teams: 8,
    team_size: 4,
    registration_starts_at: iso(-60 * 60 * 1000),
    registration_ends_at: iso(60 * 60 * 1000),
    tournament_starts_at: iso(2 * 60 * 60 * 1000),
    visibility: "public",
    waitlist_enabled: true,
    eligibility: { requires_ingame_id: false },
    ...overrides,
  };
}

async function createOpenTournament(organizer, overrides = {}) {
  const payload = tournamentPayload(overrides);
  const { data: id, error } = await organizer.rpc("create_tournament", { p_payload: payload });
  if (error) throw new Error(`create_tournament: ${error.message}`);
  for (const status of ["published", "registration_open"]) {
    const { error: statusError } = await organizer.rpc("set_tournament_status", {
      p_tournament_id: id,
      p_status: status,
    });
    if (statusError) throw new Error(`set_tournament_status(${status}): ${statusError.message}`);
  }
  return id;
}

async function createMatch(organizer, tournamentId, {
  round = "Group Stage",
  number = 1,
  maxEntries = null,
} = {}) {
  const { data, error } = await organizer.rpc("create_match", {
    p_tournament_id: tournamentId,
    p_round_name: `${round} ${run}`,
    p_match_number: number,
    p_mode: "br",
    p_max_entries: maxEntries,
    p_scheduled_at: new Date(Date.now() + 3600000).toISOString(),
  });
  if (error) throw new Error(`create_match: ${error.message}`);
  return data;
}

async function createSquadAndRegister(captainClient, players, tournamentId) {
  const { data: teamId, error: teamError } = await captainClient.rpc("create_team", {
    p_name: `Squad ${run}`,
    p_tag: "SQD",
  });
  if (teamError) throw new Error(`create_team: ${teamError.message}`);

  for (const player of players) {
    const { data: token, error: inviteError } = await captainClient.rpc("invite_to_team", {
      p_team_id: teamId,
      p_email: player.email,
      p_expires_hours: 24,
    });
    if (inviteError) throw new Error(`invite_to_team: ${inviteError.message}`);
    const { error: acceptError } = await player.client.rpc("accept_team_invitation", { p_token: token });
    if (acceptError) throw new Error(`accept_team_invitation: ${acceptError.message}`);
  }

  const { data: entry, error: entryError } = await captainClient.rpc("register_tournament_entry", {
    p_tournament_id: tournamentId,
    p_team_id: teamId,
  });
  if (entryError) throw new Error(`register_tournament_entry: ${entryError.message}`);
  return { teamId, entryId: entry.entry_id };
}

async function registerSolo(client, tournamentId) {
  const { data, error } = await client.rpc("register_tournament_entry", {
    p_tournament_id: tournamentId,
  });
  if (error) throw new Error(`register_tournament_entry(solo): ${error.message}`);
  return data.entry_id;
}

async function countEntries(matchId) {
  const { count, error } = await admin
    .from("match_entries")
    .select("*", { count: "exact", head: true })
    .eq("match_id", matchId);
  if (error) throw new Error(`count match_entries: ${error.message}`);
  return count;
}

async function main() {
  await ensureRpcsVisible();

  const organizer = await makeUser("org");
  const captain = await makeUser("captain");
  const players = [await makeUser("p1"), await makeUser("p2"), await makeUser("p3")];
  const outsider = await makeUser("outsider");
  const soloUsers = [];
  for (let i = 0; i < 6; i += 1) soloUsers.push(await makeUser(`solo${i}`));

  const organizerClient = await signIn(organizer);
  const captainClient = await signIn(captain);
  const p1Client = await signIn(players[0]);
  const p2Client = await signIn(players[1]);
  const p3Client = await signIn(players[2]);
  const outsiderClient = await signIn(outsider);
  const anonClient = clientFor();
  const soloClients = [];
  for (const user of soloUsers) soloClients.push(await signIn(user));

  const playersWithClient = [
    { ...players[0], client: p1Client },
    { ...players[1], client: p2Client },
    { ...players[2], client: p3Client },
  ];

  // ======================================================= squad tournament
  const tournamentId = await createOpenTournament(organizerClient, {
    format: "squad",
    team_size: 4,
    max_teams: 4,
  });

  const { teamId, entryId } = await createSquadAndRegister(
    captainClient,
    playersWithClient,
    tournamentId
  );

  // -------------------------------------------------------- team staff auth
  const staffSelf = await captainClient.rpc("is_team_staff", { p_team_id: teamId });
  check("team staff: owner can check own permissions", !staffSelf.error && staffSelf.data === true, staffSelf.error?.message ?? JSON.stringify(staffSelf.data));

  const staffMember = await p1Client.rpc("is_team_staff", { p_team_id: teamId });
  check("team staff: regular member is not staff", !staffMember.error && staffMember.data === false, staffMember.error?.message ?? JSON.stringify(staffMember.data));

  const staffOutsider = await outsiderClient.rpc("is_team_staff", { p_team_id: teamId });
  check("team staff: outsider is not staff", !staffOutsider.error && staffOutsider.data === false, staffOutsider.error?.message ?? JSON.stringify(staffOutsider.data));

  await expectAnyFailure(
    "team staff: anonymous caller is denied",
    anonClient.rpc("is_team_staff", { p_team_id: teamId }),
    ["permission denied", "AUTH_REQUIRED", "Could not find the function", "schema cache"]
  );

  const arbitraryId = await captainClient.rpc("is_team_staff", {
    p_team_id: teamId,
    p_user_id: outsider.id,
  });
  check(
    "team staff: caller cannot supply an arbitrary user id",
    Boolean(arbitraryId.error),
    arbitraryId.error ? errorText(arbitraryId.error) : `unexpected success: ${JSON.stringify(arbitraryId.data)}`
  );

  const memberUpdate = await p1Client
    .from("team_members")
    .update({ role: "captain" })
    .eq("team_id", teamId)
    .eq("user_id", players[0].id)
    .select("user_id, role");
  check(
    "team staff RLS: regular member cannot promote themselves",
    !memberUpdate.error && (memberUpdate.data?.length ?? 0) === 0,
    memberUpdate.error?.message ?? JSON.stringify(memberUpdate.data)
  );

  const outsiderUpdate = await outsiderClient
    .from("team_members")
    .update({ role: "captain" })
    .eq("team_id", teamId)
    .eq("user_id", players[0].id)
    .select("user_id, role");
  check(
    "team staff RLS: outsider cannot modify team membership",
    !outsiderUpdate.error && (outsiderUpdate.data?.length ?? 0) === 0,
    outsiderUpdate.error?.message ?? JSON.stringify(outsiderUpdate.data)
  );

  const { data: unchangedMember, error: unchangedMemberError } = await admin
    .from("team_members")
    .select("role")
    .eq("team_id", teamId)
    .eq("user_id", players[0].id)
    .single();
  check(
    "team staff RLS: rejected promotions did not change the roster",
    !unchangedMemberError && unchangedMember?.role === "member",
    unchangedMemberError?.message ?? JSON.stringify(unchangedMember)
  );

  // -------------------------------------------------------- match lifecycle
  const matchId = await createMatch(organizerClient, tournamentId, {
    round: "Group Stage",
    number: 1,
    maxEntries: 8,
  });

  const { error: updateError } = await organizerClient.rpc("update_match", {
    p_match_id: matchId,
    p_payload: { round_name: `Group Stage Updated ${run}`, max_entries: 8 },
  });
  check("update_match succeeds", !updateError, updateError?.message);

  const { data: regs, error: regsError } = await captainClient
    .from("tournament_registrations")
    .select("id")
    .eq("tournament_id", tournamentId)
    .eq("status", "confirmed");
  check("has confirmed squad registration", !regsError && (regs?.length ?? 0) === 1, regsError?.message ?? JSON.stringify(regs));
  const regId = entryId ?? regs?.[0]?.id;

  const assign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: matchId,
    p_registration_ids: [regId],
  });
  check("assign_match_entries assigns one registration", !assign.error && (await countEntries(matchId)) === 1, assign.error?.message);

  await expectFailure(
    "duplicate assignment rejected",
    organizerClient.rpc("assign_match_entries", {
      p_match_id: matchId,
      p_registration_ids: [regId],
    }),
    "ENTRY_ALREADY_ASSIGNED"
  );

  const remove = await organizerClient.rpc("remove_match_entry", {
    p_match_id: matchId,
    p_registration_id: regId,
  });
  check("remove_match_entry succeeds", !remove.error && (await countEntries(matchId)) === 0, remove.error?.message);

  const reassign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: matchId,
    p_registration_ids: [regId],
  });
  check("re-assign after removal succeeds", !reassign.error && (await countEntries(matchId)) === 1, reassign.error?.message);

  await expectFailure(
    "non-organizer cannot assign entries",
    outsiderClient.rpc("assign_match_entries", {
      p_match_id: matchId,
      p_registration_ids: [regId],
    }),
    "NOT_TOURNAMENT_ORGANIZER"
  );

  // -------------------------------------------------------- credentials
  const releaseAt = new Date(Date.now() + 30000).toISOString();
  const setCred = await organizerClient.rpc("set_match_credentials", {
    p_match_id: matchId,
    p_room_id: "ROOM12345",
    p_room_password: "SecretPass123",
    p_release_at: releaseAt,
  });
  check("set_match_credentials succeeds", !setCred.error, setCred.error?.message);

  const start = await organizerClient.rpc("start_match", { p_match_id: matchId });
  check("start_match succeeds", !start.error, start.error?.message);

  const { data: startedMatch, error: startedMatchError } = await organizerClient
    .from("matches")
    .select("status, started_at")
    .eq("id", matchId)
    .single();
  check(
    "match status is in_progress",
    !startedMatchError && startedMatch?.status === "in_progress" && startedMatch?.started_at !== null,
    startedMatchError?.message ?? JSON.stringify(startedMatch)
  );

  const complete = await organizerClient.rpc("complete_match", { p_match_id: matchId });
  check("complete_match succeeds", !complete.error, complete.error?.message);

  const { data: completedMatch, error: completedMatchError } = await organizerClient
    .from("matches")
    .select("status, ended_at")
    .eq("id", matchId)
    .single();
  check(
    "match status is completed",
    !completedMatchError && completedMatch?.status === "completed" && completedMatch?.ended_at !== null,
    completedMatchError?.message ?? JSON.stringify(completedMatch)
  );

  await expectFailure(
    "cannot assign entries after match completed",
    organizerClient.rpc("assign_match_entries", {
      p_match_id: matchId,
      p_registration_ids: [regId],
    }),
    "MATCH_NOT_EDITABLE"
  );

  await expectFailure(
    "credentials not released before release_at",
    p1Client.rpc("get_match_credentials", { p_match_id: matchId }),
    "CREDENTIALS_NOT_RELEASED"
  );

  await expectFailure(
    "outsider cannot access credentials before release",
    outsiderClient.rpc("get_match_credentials", { p_match_id: matchId }),
    "CREDENTIALS_NOT_RELEASED"
  );

  console.log("Waiting for credential release window (35s)...");
  await new Promise((resolve) => setTimeout(resolve, 35000));

  const creds = await p1Client.rpc("get_match_credentials", { p_match_id: matchId });
  check(
    "assigned participant can access credentials after release",
    !creds.error && creds.data?.room_id === "ROOM12345",
    creds.error?.message ?? JSON.stringify(creds.data)
  );

  const creds2 = await p2Client.rpc("get_match_credentials", { p_match_id: matchId });
  check(
    "all assigned squad members can access credentials",
    !creds2.error && creds2.data?.room_id === "ROOM12345",
    creds2.error?.message ?? JSON.stringify(creds2.data)
  );

  const { data: accessLogs, error: accessLogsError } = await organizerClient
    .from("match_credential_access")
    .select("user_id, access_granted")
    .eq("match_id", matchId)
    .order("accessed_at", { ascending: false })
    .limit(10);
  check(
    "credential access audit logged",
    !accessLogsError && accessLogs?.some((log) => log.access_granted === true),
    accessLogsError?.message ?? JSON.stringify(accessLogs)
  );

  // -------------------------------------------------------- result lifecycle
  const draft = await organizerClient.rpc("save_result_draft", {
    p_match_id: matchId,
    p_registration_id: regId,
    p_rank: 1,
    p_kills: 5,
    p_placement_points: 10,
    p_kill_points: 5,
    p_total_points: 15,
    p_scoring_snapshot: { placement_points: { 1: 10 }, kill_points: 1, scoring_mode: "auto" },
  });
  check("save_result_draft creates a draft", !draft.error, draft.error?.message);

  const draftUpdate = await organizerClient.rpc("save_result_draft", {
    p_match_id: matchId,
    p_registration_id: regId,
    p_rank: 2,
    p_kills: 3,
    p_placement_points: 5,
    p_kill_points: 3,
    p_total_points: 8,
    p_scoring_snapshot: {},
  });
  check("save_result_draft updates an existing draft", !draftUpdate.error, draftUpdate.error?.message);

  const { data: updatedDraft, error: updatedDraftError } = await admin
    .from("results")
    .select("rank, status, total_points")
    .eq("match_id", matchId)
    .eq("registration_id", regId)
    .single();
  check(
    "draft update persisted (rank=2, status=draft)",
    !updatedDraftError && updatedDraft?.rank === 2 && updatedDraft?.status === "draft" && updatedDraft?.total_points === 8,
    updatedDraftError?.message ?? JSON.stringify(updatedDraft)
  );

  const publish = await organizerClient.rpc("publish_provisional_results", { p_match_id: matchId });
  check("publish_provisional_results succeeds", !publish.error, publish.error?.message);

  const { data: provisional, error: provisionalError } = await admin
    .from("results")
    .select("rank, status, total_points")
    .eq("match_id", matchId)
    .eq("registration_id", regId)
    .single();
  check(
    "result is provisional after publishing",
    !provisionalError && provisional?.status === "provisional" && provisional?.rank === 2,
    provisionalError?.message ?? JSON.stringify(provisional)
  );

  await expectFailure(
    "draft save over a provisional result is rejected",
    organizerClient.rpc("save_result_draft", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_rank: 99,
      p_kills: 99,
      p_placement_points: 99,
      p_kill_points: 99,
      p_total_points: 99,
      p_scoring_snapshot: {},
    }),
    "RESULT_NOT_EDITABLE"
  );

  const { data: afterProvReject, error: afterProvRejectError } = await admin
    .from("results")
    .select("rank, status, total_points")
    .eq("match_id", matchId)
    .eq("registration_id", regId)
    .single();
  check(
    "rejected provisional overwrite did not change the result",
    !afterProvRejectError && afterProvReject?.rank === 2 && afterProvReject?.status === "provisional" && afterProvReject?.total_points === 8,
    afterProvRejectError?.message ?? JSON.stringify(afterProvReject)
  );

  const finalize = await organizerClient.rpc("finalize_match_results", { p_match_id: matchId });
  check("finalize_match_results succeeds", !finalize.error, finalize.error?.message);

  const { data: finalized, error: finalizedError } = await admin
    .from("results")
    .select("rank, status, total_points, finalized_at")
    .eq("match_id", matchId)
    .eq("registration_id", regId)
    .single();
  check(
    "result is finalized with a timestamp",
    !finalizedError && finalized?.status === "finalized" && finalized?.finalized_at !== null && finalized?.rank === 2,
    finalizedError?.message ?? JSON.stringify(finalized)
  );

  await expectFailure(
    "draft save over a finalized result is rejected",
    organizerClient.rpc("save_result_draft", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_rank: 100,
      p_kills: 100,
      p_placement_points: 100,
      p_kill_points: 100,
      p_total_points: 100,
      p_scoring_snapshot: {},
    }),
    "RESULT_NOT_EDITABLE"
  );

  const { data: afterFinalReject, error: afterFinalRejectError } = await admin
    .from("results")
    .select("rank, status, total_points")
    .eq("match_id", matchId)
    .eq("registration_id", regId)
    .single();
  check(
    "rejected finalized overwrite did not change the result",
    !afterFinalRejectError && afterFinalReject?.rank === 2 && afterFinalReject?.status === "finalized" && afterFinalReject?.total_points === 8,
    afterFinalRejectError?.message ?? JSON.stringify(afterFinalReject)
  );

  // -------------------------------------------------------- disputes
  const dispute1 = await p2Client.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: regId,
    p_reason: "Kill count incorrect",
    p_evidence_paths: ["evidence/dispute1.png"],
  });
  check(
    "valid squad participant can submit a dispute",
    !dispute1.error && Boolean(dispute1.data),
    dispute1.error?.message ?? JSON.stringify(dispute1.data)
  );

  const { data: persistedDispute, error: persistedDisputeError } = await admin
    .from("disputes")
    .select("id, submitted_by, status, registration_id")
    .eq("id", dispute1.data)
    .single();
  check(
    "submitted dispute is persisted with the caller as submitter",
    !persistedDisputeError && persistedDispute?.submitted_by === players[1].id && persistedDispute?.status === "submitted",
    persistedDisputeError?.message ?? JSON.stringify(persistedDispute)
  );

  await expectFailure(
    "duplicate active dispute is rejected",
    p2Client.rpc("submit_dispute", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_reason: "Another reason",
      p_evidence_paths: [],
    }),
    "DISPUTE_ALREADY_EXISTS"
  );

  await expectFailure(
    "user outside the squad cannot submit a dispute",
    outsiderClient.rpc("submit_dispute", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_reason: "Test",
      p_evidence_paths: [],
    }),
    "ENTRY_NOT_ASSIGNED"
  );

  await expectFailure(
    "unauthenticated caller cannot submit a dispute",
    anonClient.rpc("submit_dispute", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_reason: "Test",
      p_evidence_paths: [],
    }),
    "AUTH_REQUIRED"
  );

  // Resolve the first dispute so another squad member can submit.
  const resolveFirst = await admin
    .from("disputes")
    .update({
      status: "resolved",
      resolved_at: new Date().toISOString(),
      resolution: "Resolved during automated verification",
      resolution_type: "rejected",
    })
    .eq("id", dispute1.data)
    .select("id, status")
    .single();
  check(
    "setup: first dispute resolved",
    !resolveFirst.error && resolveFirst.data?.status === "resolved",
    resolveFirst.error?.message ?? JSON.stringify(resolveFirst.data)
  );

  const disputeByP1 = await p1Client.rpc("submit_dispute", {
    p_match_id: matchId,
    p_registration_id: regId,
    p_reason: "Squad member resubmission",
    p_evidence_paths: [],
  });
  check(
    "squad member can submit for their registered squad",
    !disputeByP1.error && Boolean(disputeByP1.data),
    disputeByP1.error?.message ?? JSON.stringify(disputeByP1.data)
  );

  await expectFailure(
    "outsider still cannot submit after a resolved dispute",
    outsiderClient.rpc("submit_dispute", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_reason: "Test",
      p_evidence_paths: [],
    }),
    "ENTRY_NOT_ASSIGNED"
  );

  // Resolve again, then race two legitimate submitters.
  const resolveSecond = await admin
    .from("disputes")
    .update({
      status: "resolved",
      resolved_at: new Date().toISOString(),
      resolution: "Resolved before concurrency test",
      resolution_type: "rejected",
    })
    .eq("id", disputeByP1.data)
    .select("id")
    .single();
  check("setup: second dispute resolved", !resolveSecond.error, resolveSecond.error?.message);

  const concurrent = await Promise.all([
    p1Client.rpc("submit_dispute", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_reason: "Concurrent A",
      p_evidence_paths: [],
    }),
    p2Client.rpc("submit_dispute", {
      p_match_id: matchId,
      p_registration_id: regId,
      p_reason: "Concurrent B",
      p_evidence_paths: [],
    }),
  ]);

  const concurrentSuccesses = concurrent.filter((result) => !result.error).length;
  const concurrentDuplicates = concurrent.filter(
    (result) => result.error && errorText(result.error).includes("DISPUTE_ALREADY_EXISTS")
  ).length;
  check(
    "concurrent submissions produce exactly one active dispute",
    concurrentSuccesses === 1 && concurrentDuplicates === 1,
    concurrent
      .map((result) => (result.error ? errorText(result.error) : `ok:${result.data}`))
      .join(" | ")
  );

  const { data: activeDisputes, error: activeDisputesError } = await admin
    .from("disputes")
    .select("id, submitted_by, status")
    .eq("match_id", matchId)
    .eq("registration_id", regId)
    .in("status", ["submitted", "under_review"]);
  check(
    "database contains exactly one active dispute after the race",
    !activeDisputesError && activeDisputes?.length === 1,
    activeDisputesError?.message ?? JSON.stringify(activeDisputes)
  );
  const activeDisputeId = activeDisputes?.[0]?.id;

  // -------------------------------------------------------- moderators
  const modUser = await makeUser("mod");
  const modInsert = await admin.from("tournament_organizers").insert({
    tournament_id: tournamentId,
    user_id: modUser.id,
    role: "moderator",
  });
  check("setup: moderator role created", !modInsert.error, modInsert.error?.message);

  const assignMod = await organizerClient.rpc("assign_dispute_moderator", {
    p_dispute_id: activeDisputeId,
    p_moderator_id: modUser.id,
  });
  check("valid moderator assignment succeeds", !assignMod.error, assignMod.error?.message);

  const { data: moderated, error: moderatedError } = await admin
    .from("disputes")
    .select("status, moderator_id")
    .eq("id", activeDisputeId)
    .single();
  check(
    "moderator assignment persisted (under_review)",
    !moderatedError && moderated?.status === "under_review" && moderated?.moderator_id === modUser.id,
    moderatedError?.message ?? JSON.stringify(moderated)
  );

  const conflictModInsert = await admin.from("tournament_organizers").insert({
    tournament_id: tournamentId,
    user_id: players[1].id,
    role: "moderator",
  });
  check("setup: conflicting moderator role created", !conflictModInsert.error, conflictModInsert.error?.message);

  await expectFailure(
    "moderator with a conflict of interest is rejected",
    organizerClient.rpc("assign_dispute_moderator", {
      p_dispute_id: activeDisputeId,
      p_moderator_id: players[1].id,
    }),
    "MODERATOR_CONFLICT"
  );

  await expectFailure(
    "non-moderator cannot be assigned to a dispute",
    organizerClient.rpc("assign_dispute_moderator", {
      p_dispute_id: activeDisputeId,
      p_moderator_id: outsider.id,
    }),
    "NOT_DISPUTE_MODERATOR"
  );

  // -------------------------------------------------------- capacity fixtures
  const soloTournamentId = await createOpenTournament(organizerClient, {
    format: "solo",
    max_teams: 10,
  });
  const soloRegs = [];
  for (const client of soloClients) {
    soloRegs.push(await registerSolo(client, soloTournamentId));
  }
  check("six separate solo registrations created", soloRegs.length === 6 && new Set(soloRegs).size === 6);

  // one registration
  const mSingle = await createMatch(organizerClient, soloTournamentId, { round: "Single", number: 1, maxEntries: 4 });
  const singleAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mSingle,
    p_registration_ids: [soloRegs[0]],
  });
  check("capacity: one registration assigned", !singleAssign.error && (await countEntries(mSingle)) === 1, singleAssign.error?.message);

  // multiple separate registrations in one batch
  const mBatch = await createMatch(organizerClient, soloTournamentId, { round: "Batch", number: 1, maxEntries: 4 });
  const batchAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mBatch,
    p_registration_ids: soloRegs.slice(0, 3),
  });
  check("capacity: batch of three separate registrations assigned", !batchAssign.error && (await countEntries(mBatch)) === 3, batchAssign.error?.message);

  // exactly at capacity
  const mExact = await createMatch(organizerClient, soloTournamentId, { round: "Exact", number: 1, maxEntries: 3 });
  const exactAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mExact,
    p_registration_ids: soloRegs.slice(0, 3),
  });
  check("capacity: batch exactly at capacity succeeds", !exactAssign.error && (await countEntries(mExact)) === 3, exactAssign.error?.message);

  // exceeding capacity leaves no partial rows
  const mOver = await createMatch(organizerClient, soloTournamentId, { round: "Over", number: 1, maxEntries: 2 });
  const overAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mOver,
    p_registration_ids: soloRegs.slice(0, 3),
  });
  check(
    "capacity: batch exceeding capacity is rejected",
    Boolean(overAssign.error) && errorText(overAssign.error).includes("INVALID_ENTRY_FOR_MATCH"),
    overAssign.error ? errorText(overAssign.error) : "expected failure"
  );
  check("capacity: rejected oversized batch inserted nothing", (await countEntries(mOver)) === 0);

  // duplicate id inside the batch
  const mDup = await createMatch(organizerClient, soloTournamentId, { round: "Duplicate", number: 1, maxEntries: 4 });
  const dupAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mDup,
    p_registration_ids: [soloRegs[0], soloRegs[0]],
  });
  check(
    "capacity: duplicate id inside the batch is rejected",
    Boolean(dupAssign.error) && errorText(dupAssign.error).includes("DUPLICATE_ENTRY_IN_BATCH"),
    dupAssign.error ? errorText(dupAssign.error) : "expected failure"
  );
  check("capacity: duplicate batch inserted nothing", (await countEntries(mDup)) === 0);

  // already assigned registration
  const mAlready = await createMatch(organizerClient, soloTournamentId, { round: "Already", number: 1, maxEntries: 4 });
  const firstAlready = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mAlready,
    p_registration_ids: [soloRegs[0]],
  });
  check("capacity: setup registration assigned", !firstAlready.error, firstAlready.error?.message);
  const alreadyAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mAlready,
    p_registration_ids: [soloRegs[0], soloRegs[1]],
  });
  check(
    "capacity: already-assigned registration rejects the whole batch",
    Boolean(alreadyAssign.error) && errorText(alreadyAssign.error).includes("ENTRY_ALREADY_ASSIGNED"),
    alreadyAssign.error ? errorText(alreadyAssign.error) : "expected failure"
  );
  check("capacity: rejected already-assigned batch added no new row", (await countEntries(mAlready)) === 1);

  // NULL / empty arrays
  const mEmpty = await createMatch(organizerClient, soloTournamentId, { round: "Empty", number: 1, maxEntries: 4 });
  await expectFailure(
    "capacity: empty array is rejected",
    organizerClient.rpc("assign_match_entries", { p_match_id: mEmpty, p_registration_ids: [] }),
    "INVALID_ENTRY_FOR_MATCH"
  );
  await expectFailure(
    "capacity: null array is rejected",
    organizerClient.rpc("assign_match_entries", { p_match_id: mEmpty, p_registration_ids: null }),
    "INVALID_ENTRY_FOR_MATCH"
  );
  check("capacity: empty/null batches inserted nothing", (await countEntries(mEmpty)) === 0);

  // registration from another tournament
  const mForeign = await createMatch(organizerClient, soloTournamentId, { round: "Foreign", number: 1, maxEntries: 4 });
  const foreignAssign = await organizerClient.rpc("assign_match_entries", {
    p_match_id: mForeign,
    p_registration_ids: [regId],
  });
  check(
    "capacity: registration from another tournament is rejected",
    Boolean(foreignAssign.error) && errorText(foreignAssign.error).includes("INVALID_ENTRY_FOR_MATCH"),
    foreignAssign.error ? errorText(foreignAssign.error) : "expected failure"
  );
  check("capacity: foreign registration inserted nothing", (await countEntries(mForeign)) === 0);

  // concurrent assignment cannot exceed capacity
  const mRace = await createMatch(organizerClient, soloTournamentId, { round: "Race", number: 1, maxEntries: 1 });
  const race = await Promise.all([
    organizerClient.rpc("assign_match_entries", { p_match_id: mRace, p_registration_ids: [soloRegs[0]] }),
    organizerClient.rpc("assign_match_entries", { p_match_id: mRace, p_registration_ids: [soloRegs[1]] }),
  ]);
  const raceSuccesses = race.filter((result) => !result.error).length;
  const raceCapacityFailures = race.filter(
    (result) => result.error && errorText(result.error).includes("INVALID_ENTRY_FOR_MATCH")
  ).length;
  check(
    "capacity: concurrent assignments produce one success and one rejection",
    raceSuccesses === 1 && raceCapacityFailures === 1,
    race.map((result) => (result.error ? errorText(result.error) : "ok")).join(" | ")
  );
  check("capacity: concurrent race leaves exactly one entry", (await countEntries(mRace)) === 1);

  console.log(
    `\nPhase 4 DB checks: ${passed} passed, ${failed} failed, ${blocked} blocked.`
  );
  process.exit(failed === 0 && blocked === 0 ? 0 : 1);
}

main().catch((error) => {
  console.error(`FATAL ${error.stack ?? error}`);
  process.exit(1);
});
