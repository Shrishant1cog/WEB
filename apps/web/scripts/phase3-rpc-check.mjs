// Phase 3 database verification against a running local Supabase stack.
//
// Exercises the SECURITY DEFINER RPCs with real authenticated users:
// registration, capacity, waitlist promotion, duplicate prevention,
// roster validation, eligibility and team invitations.
//
// Usage:
//   node scripts/phase3-rpc-check.mjs
// with SUPABASE_URL, SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY set
// (values from `supabase status`).

import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !anonKey || !serviceKey) {
  console.error("Missing SUPABASE_URL/SUPABASE_ANON_KEY/SUPABASE_SERVICE_ROLE_KEY.");
  process.exit(2);
}

const run = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
const password = `Phase3!${run}`;
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

const admin = createClient(url, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

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
    title: `Phase3 Cup ${run} ${Math.floor(Math.random() * 100000)}`,
    description: "Automated Phase 3 verification",
    format: "solo",
    mode: "br",
    max_teams: 1,
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

async function createOpenTournament(organizer, overrides = {}) {
  const payload = tournamentPayload(overrides);
  const { data: id, error } = await organizer.rpc("create_tournament", {
    p_payload: payload,
  });
  if (error) throw new Error(`create_tournament: ${error.message}`);

  for (const status of ["published", "registration_open"]) {
    const { error: statusError } = await organizer.rpc("set_tournament_status", {
      p_tournament_id: id,
      p_status: status,
    });
    if (statusError) {
      throw new Error(`set_tournament_status(${status}): ${statusError.message}`);
    }
  }
  return id;
}

async function main() {
  const organizer = await makeUser("organizer");
  const players = [];
  for (let i = 0; i < 10; i += 1) {
    players.push(await makeUser(`player${i}`));
  }

  const organizerClient = await signIn(organizer);
  const p = [];
  for (const player of players) {
    p.push(await signIn(player));
  }

  // ---------------------------------------------------------------- solo flow
  const soloId = await createOpenTournament(organizerClient);

  const { data: listing, error: listingError } = await p[0]
    .from("tournament_public_listing")
    .select("id, status, confirmed_entries, waitlisted_entries")
    .eq("id", soloId)
    .single();
  check(
    "public listing exposes open tournament",
    !listingError && listing?.status === "registration_open",
    listingError?.message
  );

  const { data: first, error: firstError } = await p[0].rpc(
    "register_tournament_entry",
    { p_tournament_id: soloId, p_team_id: null }
  );
  check(
    "first solo entry is confirmed",
    !firstError && first?.status === "confirmed",
    firstError?.message
  );

  const { data: second, error: secondError } = await p[1].rpc(
    "register_tournament_entry",
    { p_tournament_id: soloId }
  );
  check(
    "second entry is waitlisted at position 1",
    !secondError && second?.status === "waitlisted" && second?.waitlist_position === 1,
    secondError?.message ?? JSON.stringify(second)
  );

  await expectFailure(
    "duplicate registration is rejected",
    p[1].rpc("register_tournament_entry", { p_tournament_id: soloId }),
    "ALREADY_REGISTERED"
  );

  const { data: withdrawal, error: withdrawalError } = await p[0].rpc(
    "withdraw_tournament_entry",
    { p_entry_id: first.entry_id }
  );
  check(
    "withdrawal promotes the next waitlisted entry",
    !withdrawalError &&
      withdrawal?.status === "cancelled" &&
      withdrawal?.promoted_entry_id === second.entry_id,
    withdrawalError?.message
  );

  const { data: promoted, error: promotedError } = await p[1]
    .from("tournament_registrations")
    .select("status")
    .eq("id", second.entry_id)
    .single();
  check(
    "promoted entry is now confirmed",
    promoted?.status === "confirmed",
    promotedError?.message
  );

  // -------------------------------------------------------------- full, no waitlist
  const fullId = await createOpenTournament(organizerClient, {
    max_teams: 1,
    waitlist_enabled: false,
  });
  const { error: fullFirst } = await p[2].rpc("register_tournament_entry", {
    p_tournament_id: fullId,
  });
  check("first entry in no-waitlist tournament is confirmed", !fullFirst, fullFirst?.message);

  await expectFailure(
    "capacity is enforced when the waitlist is disabled",
    p[3].rpc("register_tournament_entry", { p_tournament_id: fullId }),
    "TOURNAMENT_FULL"
  );

  // ---------------------------------------------------------------- team flow
  const squadId = await createOpenTournament(organizerClient, {
    format: "duo",
    team_size: 2,
    max_teams: 4,
  });

  const { data: teamId, error: teamError } = await p[4].rpc("create_team", {
    p_name: `Alpha ${run}`,
    p_tag: "AL",
  });
  check("team creation succeeds", !teamError && Boolean(teamId), teamError?.message);

  const { data: token, error: inviteError } = await p[4].rpc("invite_to_team", {
    p_team_id: teamId,
    p_email: players[5].email,
    p_expires_hours: 24,
  });
  check(
    "invitation returns a one-time token",
    !inviteError && typeof token === "string" && token.length === 64,
    inviteError?.message
  );

  const { data: joinedTeam, error: acceptError } = await p[5].rpc(
    "accept_team_invitation",
    { p_token: token }
  );
  check(
    "invited player joins the team",
    !acceptError && joinedTeam === teamId,
    acceptError?.message
  );

  await expectFailure(
    "non-captain cannot register a team",
    p[5].rpc("register_tournament_entry", {
      p_tournament_id: squadId,
      p_team_id: teamId,
    }),
    "ONLY_CAPTAIN_CAN_REGISTER"
  );

  const { data: teamEntry, error: teamEntryError } = await p[4].rpc(
    "register_tournament_entry",
    { p_tournament_id: squadId, p_team_id: teamId }
  );
  check(
    "captain registers a full roster",
    !teamEntryError && teamEntry?.status === "confirmed",
    teamEntryError?.message
  );

  const { data: members, error: membersError } = await p[4]
    .from("tournament_entry_members")
    .select("user_id, role")
    .eq("entry_id", teamEntry.entry_id);
  check(
    "roster snapshot has two members including the captain",
    members?.length === 2 && members.some((member) => member.role === "captain"),
    membersError?.message ?? JSON.stringify(members)
  );

  // ------------------------------------------------------- roster size validation
  const squadOfFourId = await createOpenTournament(organizerClient, {
    format: "squad",
    team_size: 4,
    max_teams: 4,
  });

  const { data: smallTeam } = await p[6].rpc("create_team", {
    p_name: `Bravo ${run}`,
    p_tag: "BR",
  });
  const { data: smallToken } = await p[6].rpc("invite_to_team", {
    p_team_id: smallTeam,
    p_email: players[7].email,
    p_expires_hours: 24,
  });
  await p[7].rpc("accept_team_invitation", { p_token: smallToken });

  await expectFailure(
    "roster smaller than team_size is rejected",
    p[6].rpc("register_tournament_entry", {
      p_tournament_id: squadOfFourId,
      p_team_id: smallTeam,
    }),
    "ROSTER_INCOMPLETE"
  );

  // ---------------------------------------------------------- in-game UID eligibility
  const uidId = await createOpenTournament(organizerClient, {
    max_teams: 8,
    eligibility: { requires_ingame_id: true },
  });

  await expectFailure(
    "missing in-game UID blocks registration",
    p[8].rpc("register_tournament_entry", { p_tournament_id: uidId }),
    "ELIGIBILITY_INGAME_ID_REQUIRED"
  );

  const uidValue = String(Date.now()).slice(-10);
  const { error: profileError } = await p[8]
    .from("profiles")
    .update({ in_game_uid: uidValue })
    .eq("id", players[8].id);
  check("player can set their own in-game UID", !profileError, profileError?.message);

  const { data: eligibleEntry, error: eligibleError } = await p[8].rpc(
    "register_tournament_entry",
    { p_tournament_id: uidId }
  );
  check(
    "registration succeeds after adding the UID",
    !eligibleError && eligibleEntry?.status === "confirmed",
    eligibleError?.message
  );

  // ------------------------------------------------------------ organizer-only RPC
  await expectFailure(
    "non-organizer cannot open registration",
    p[9].rpc("set_tournament_status", {
      p_tournament_id: soloId,
      p_status: "registration_closed",
    }),
    "NOT_TOURNAMENT_ORGANIZER"
  );

  console.log(`\nPhase 3 DB checks: ${passed} passed, ${failed} failed.`);
  process.exit(failed === 0 ? 0 : 1);
}

main().catch((error) => {
  console.error(`FATAL ${error.stack ?? error}`);
  process.exit(1);
});
