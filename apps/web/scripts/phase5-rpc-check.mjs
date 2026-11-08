// Phase 5 database verification — notifications, delivery queue, platform
// administration, organizer approval, abuse reporting and moderation scope.
//
// Every assertion is one of:
//   PASS     behaviour was actually verified
//   FAIL     behaviour is incorrect
//   BLOCKED  infrastructure prevented the test (script exits non-zero)
//
// Usage (local stack values come from `supabase status`):
//   node scripts/phase5-rpc-check.mjs
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
const password = `Phase5!${run}`;
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
  return `${error.message ?? ""} ${error.details ?? ""} ${error.hint ?? ""} ${error.code ?? ""}`;
}

async function expectFailure(name, promise, keys) {
  const result = await promise;
  const error = result?.error;
  const text = errorText(error);
  const wanted = Array.isArray(keys) ? keys : [keys];
  check(
    name,
    Boolean(error) && wanted.some((key) => text.includes(key)),
    error ? text : "expected an error but the call succeeded"
  );
  return result;
}

const admin = createClient(url, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// -------------------------------------------------------- schema verification
const requiredRpcs = [
  "create_notification",
  "mark_notification_read",
  "mark_all_notifications_read",
  "set_notification_preference",
  "register_device_token",
  "remove_device_token",
  "process_scheduled_notifications",
  "create_tournament_announcement",
  "is_platform_admin",
  "platform_admin_role",
  "admin_search_users",
  "admin_get_user",
  "admin_suspend_user",
  "admin_restore_user",
  "admin_list_organizers",
  "admin_set_organizer_status",
  "admin_list_tournaments",
  "admin_assign_moderator",
  "admin_remove_moderator",
  "admin_list_moderators",
  "admin_search_audit_logs",
  "admin_platform_metrics",
  "admin_set_platform_setting",
  "admin_grant_platform_admin",
  "admin_revoke_platform_admin",
  "submit_abuse_report",
  "admin_triage_abuse_report",
  "admin_resolve_abuse_report",
  "request_organizer_account",
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
      console.log(`PASS PostgREST exposes required Phase 5 RPCs (${requiredRpcs.length})`);
      passed += 1;
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
  blockedTest("PostgREST schema cache exposes Phase 5 RPCs", `missing: ${missing.join(", ")}`);
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
  const { error } = await client.auth.signInWithPassword({ email: user.email, password });
  if (error) throw new Error(`signIn ${user.email}: ${error.message}`);
  return client;
}

function tournamentPayload(overrides = {}) {
  const now = Date.now();
  const iso = (offset) => new Date(now + offset).toISOString();
  return {
    title: `Phase5 Cup ${run} ${Math.floor(Math.random() * 100000)}`,
    description: "Automated Phase 5 verification",
    format: "solo",
    mode: "br",
    max_teams: 8,
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

async function registerSolo(client, tournamentId) {
  const { data, error } = await client.rpc("register_tournament_entry", {
    p_tournament_id: tournamentId,
  });
  if (error) throw new Error(`register_tournament_entry: ${error.message}`);
  return data.entry_id;
}

async function notificationsFor(client) {
  const { data, error } = await client
    .from("notifications")
    .select("id, user_id, type, title, body, category, read_at, push_requested, dedupe_key, data")
    .order("created_at", { ascending: false });
  if (error) throw new Error(`select notifications: ${error.message}`);
  return data ?? [];
}

function hasType(rows, type) {
  return rows.some((row) => row.type === type);
}

async function scalarCount(table, filter = () => true) {
  const { data, error } = await admin.from(table).select("*");
  if (error) throw new Error(`select ${table}: ${error.message}`);
  return (data ?? []).filter(filter).length;
}

// -------------------------------------------------------- main
async function main() {
  await ensureRpcsVisible();

  const organizer = await makeUser("org");
  const playerA = await makeUser("playerA");
  const playerB = await makeUser("playerB");
  const outsider = await makeUser("outsider");
  const adminUser = await makeUser("platformadmin");
  const supportUser = await makeUser("support");

  const organizerClient = await signIn(organizer);
  const playerAClient = await signIn(playerA);
  const playerBClient = await signIn(playerB);
  const outsiderClient = await signIn(outsider);
  const anonClient = clientFor();

  // Admin is provisioned out-of-band (service role), never by a client.
  const { error: seedAdminError } = await admin
    .from("platform_admins")
    .insert({ user_id: adminUser.id, role: "super_admin", notes: "phase5 test" });
  check("admin seed: service role provisions platform admin", !seedAdminError, seedAdminError?.message);
  const adminClient = await signIn(adminUser);

  // -------------------------------------------------------- notification basics
  const tournamentId = await createOpenTournament(organizerClient, { max_teams: 2 });
  const entryA = await registerSolo(playerAClient, tournamentId);

  const aRows = await notificationsFor(playerAClient);
  check(
    "notifications: registration confirmation persisted",
    hasType(aRows, "registration_confirmed"),
    JSON.stringify(aRows.map((r) => r.type))
  );
  check(
    "notifications: category derived as registration",
    aRows.find((r) => r.type === "registration_confirmed")?.category === "registration"
  );
  check("notifications: created row has a user-owned recipient", aRows.every((r) => r.user_id === playerA.id));

  const outsiderRows = await notificationsFor(outsiderClient);
  check(
    "notifications: another user cannot read private notifications",
    outsiderRows.every((r) => r.user_id === outsider.id) && !outsiderRows.some((r) => r.user_id === playerA.id)
  );

  await expectFailure(
    "notifications: direct client INSERT is denied",
    playerAClient.from("notifications").insert({
      user_id: outsider.id,
      type: "forged",
      title: "forged",
      category: "system",
    }),
    ["permission denied", "42501"]
  );

  await expectFailure(
    "notifications: direct client UPDATE is denied",
    playerAClient.from("notifications").update({ title: "hijacked" }).eq("user_id", playerA.id),
    ["permission denied", "42501"]
  );

  await expectFailure(
    "notifications: create_notification RPC is not client-callable",
    playerAClient.rpc("create_notification", {
      p_user_id: outsider.id,
      p_type: "forged",
      p_title: "forged",
      p_body: "forged",
    }),
    ["permission denied", "Could not find the function", "schema cache", "42501"]
  );

  const target = aRows[0];
  const markOther = await outsiderClient.rpc("mark_notification_read", { p_notification_id: target.id });
  check("notifications: cannot mark another user's notification read", markOther.data === false, JSON.stringify(markOther.error ?? markOther.data));

  const markOwn = await playerAClient.rpc("mark_notification_read", { p_notification_id: target.id });
  check("notifications: owner marks a notification read", !markOwn.error && markOwn.data === true, markOwn.error?.message);
  const readBack = await notificationsFor(playerAClient);
  check("notifications: read state persisted", Boolean(readBack.find((r) => r.id === target.id)?.read_at));

  const markAll = await playerAClient.rpc("mark_all_notifications_read");
  check("notifications: mark-all-read succeeds", !markAll.error && typeof markAll.data === "number", markAll.error?.message);
  const unread = (await notificationsFor(playerAClient)).filter((r) => !r.read_at);
  check("notifications: no unread in-app notifications remain", unread.length === 0, `${unread.length} unread`);

  // -------------------------------------------------------- waitlist promotion
  const waitTournament = await createOpenTournament(organizerClient, { max_teams: 1 });
  await registerSolo(playerAClient, waitTournament);
  const waitEntryB = await registerSolo(playerBClient, waitTournament);
  const bRowsAfterWait = await notificationsFor(playerBClient);
  check("notifications: waitlist registration persisted", hasType(bRowsAfterWait, "registration_waitlisted"));

  const withdraw = await playerAClient.rpc("withdraw_tournament_entry", { p_entry_id: waitEntryB === null ? null : waitEntryB });
  // Withdraw the confirmed entry, not the waitlisted one (own entry lookup).
  const { data: ownEntries } = await playerAClient
    .from("tournament_registrations")
    .select("id, status")
    .eq("tournament_id", waitTournament);
  const confirmedEntry = (ownEntries ?? []).find((r) => r.status === "confirmed");
  if (confirmedEntry) {
    await playerAClient.rpc("withdraw_tournament_entry", { p_entry_id: confirmedEntry.id });
  }
  void withdraw;
  const bRowsAfterPromotion = await notificationsFor(playerBClient);
  check("notifications: waitlist promotion sent", hasType(bRowsAfterPromotion, "waitlist_promoted"));

  // -------------------------------------------------------- device token registration (before push notifications)
  const token = `phase5-device-${run}-${"x".repeat(20)}`;
  const register = await playerAClient.rpc("register_device_token", {
    p_token: token,
    p_platform: "android",
    p_device_name: "Phase 5 test device",
  });
  check("push: device token registered", !register.error && Boolean(register.data), register.error?.message);

  // -------------------------------------------------------- match + credentials
  const { data: matchId, error: matchError } = await organizerClient.rpc("create_match", {
    p_tournament_id: tournamentId,
    p_round_name: `Round 1 ${run}`,
    p_match_number: 1,
    p_mode: "br",
    p_scheduled_at: new Date(Date.now() + 3600000).toISOString(),
  });
  if (matchError) throw new Error(`create_match: ${matchError.message}`);

  const aRowsMatch = await notificationsFor(playerAClient);
  check("notifications: match scheduling sent to participants", hasType(aRowsMatch, "match_scheduled"));

  const { error: credError } = await organizerClient.rpc("set_match_credentials", {
    p_match_id: matchId,
    p_room_id: `room-${run}`,
    p_room_password: `pw-${run}`,
    p_release_at: new Date(Date.now() + 120000).toISOString(),
  });
  check("notifications: credentials stored for scheduled release", !credError, credError?.message);

  const { data: scheduled } = await admin
    .from("scheduled_notifications")
    .select("id, dedupe_key, processed_at")
    .eq("data->>match_id", matchId);
  check("notifications: credential release scheduled (not yet sent)", (scheduled ?? []).length > 0 && (scheduled ?? []).every((s) => !s.processed_at));

  if ((scheduled ?? []).length > 0) {
    await admin
      .from("scheduled_notifications")
      .update({ scheduled_at: new Date(Date.now() - 1000).toISOString() })
      .eq("data->>match_id", matchId);
  }
  const processed = await admin.rpc("process_scheduled_notifications", { p_limit: 100 });
  check("notifications: scheduled processor runs", !processed.error && (processed.data ?? 0) > 0, processed.error?.message ?? String(processed.data));
  const processedAgain = await admin.rpc("process_scheduled_notifications", { p_limit: 100 });
  check("notifications: scheduled processing is idempotent", !processedAgain.error && processedAgain.data === 0, processedAgain.error?.message ?? String(processedAgain.data));
  const aRowsCred = await notificationsFor(playerAClient);
  check("notifications: credential release delivered in-app", hasType(aRowsCred, "credentials_released"));

  // -------------------------------------------------------- results + disputes
  const { data: regA } = await admin
    .from("tournament_registrations")
    .select("id")
    .eq("id", entryA)
    .single();

  const { error: provisionalError } = await admin.from("results").insert({
    match_id: matchId,
    registration_id: regA.id,
    status: "provisional",
    rank: 1,
    total_points: 10,
  });
  check("notifications: provisional result trigger fires", !provisionalError, provisionalError?.message);
  const aRowsResult = await notificationsFor(playerAClient);
  check("notifications: result publication sent", hasType(aRowsResult, "result_published"));

  const { data: resultRow } = await admin
    .from("results")
    .select("id")
    .eq("match_id", matchId)
    .eq("registration_id", regA.id)
    .single();
  if (resultRow) {
    await admin.from("results").update({ status: "finalized" }).eq("id", resultRow.id);
  }
  const aRowsFinal = await notificationsFor(playerAClient);
  check("notifications: result finalization sent", hasType(aRowsFinal, "result_finalized"));

  const { data: disputeId, error: disputeError } = await admin
    .from("disputes")
    .insert({
      match_id: matchId,
      registration_id: regA.id,
      submitted_by: playerA.id,
      reason: `Automated dispute ${run}`,
      evidence_paths: [],
    })
    .select("id")
    .single();
  check("notifications: dispute submission trigger fires", !disputeError, disputeError?.message);

  if (disputeId) {
    await admin.from("disputes").update({ status: "under_review" }).eq("id", disputeId.id);
  }
  const aRowsDispute = await notificationsFor(playerAClient);
  check("notifications: dispute update sent to reporter", hasType(aRowsDispute, "dispute_updated"));

  // -------------------------------------------------------- announcements
  const { error: announcementError } = await organizerClient.rpc("create_tournament_announcement", {
    p_tournament_id: tournamentId,
    p_title: `Announcement ${run}`,
    p_body: "Automated Phase 5 announcement body.",
    p_pinned: true,
  });
  check("notifications: organizer publishes announcement", !announcementError, announcementError?.message);
  const aRowsAnnouncement = await notificationsFor(playerAClient);
  check("notifications: announcement delivered to participant", hasType(aRowsAnnouncement, "announcement_published"));

  // -------------------------------------------------------- preferences + dedupe
  const prefOff = await playerBClient.rpc("set_notification_preference", {
    p_category: "system",
    p_in_app: false,
    p_push: false,
    p_email: false,
  });
  check("notifications: preference update succeeds", !prefOff.error, prefOff.error?.message);
  const prefRead = await playerBClient.from("notification_preferences").select("category, in_app, push, email");
  check(
    "notifications: preferences are user-scoped",
    (prefRead.data ?? []).some((p) => p.category === "system" && p.in_app === false && p.push === false),
    prefRead.error?.message
  );

  const beforeB = (await notificationsFor(playerBClient)).filter((r) => r.type === "organizer_status_changed").length;
  await adminClient.rpc("admin_set_organizer_status", { p_user_id: playerB.id, p_status: "approved" });
  const afterB = (await notificationsFor(playerBClient)).filter((r) => r.type === "organizer_status_changed").length;
  check("notifications: disabled channels suppress persistence", afterB === beforeB, `before=${beforeB} after=${afterB}`);

  await adminClient.rpc("admin_set_organizer_status", { p_user_id: playerA.id, p_status: "approved" });
  await adminClient.rpc("admin_set_organizer_status", { p_user_id: playerA.id, p_status: "approved" });
  const dedupeRows = (await notificationsFor(playerAClient)).filter((r) => r.type === "organizer_status_changed");
  check("notifications: duplicate event deduplicated", dedupeRows.length === 1, `${dedupeRows.length} rows`);

  // -------------------------------------------------------- device tokens + queue (token already registered earlier)
  const otherToken = await playerAClient.rpc("remove_device_token", { p_token: "not-my-token" });
  check("push: removing another token reports false", otherToken.data === false, otherToken.error?.message);

  const ownedTokens = await playerAClient.from("device_tokens").select("token, user_id, revoked_at");
  check(
    "push: device tokens are private",
    (ownedTokens.data ?? []).every((t) => t.user_id === playerA.id),
    ownedTokens.error?.message
  );

  await expectFailure(
    "push: direct device token INSERT is denied",
    playerAClient.from("device_tokens").insert({ user_id: playerA.id, token: `direct-${run}` }),
    ["permission denied", "42501"]
  );

  // With per-device queue, there should be one row per device token
  const queued = await admin
    .from("notification_delivery_queue")
    .select("id, notification_id, device_token, status, attempts")
    .in("notification_id", (await notificationsFor(playerAClient)).map((r) => r.id));
  check("push: notifications enqueue durable push rows (one per device)", (queued.data ?? []).length >= 1, JSON.stringify(queued.error?.message ?? queued.data?.length));

  const claim = await admin.rpc("claim_notification_delivery", { p_limit: 500 });
  check("push: delivery claim runs", !claim.error && Array.isArray(claim.data), claim.error?.message);
  const claimedForA = (claim.data ?? []).find((row) => row.token === token);
  check("push: claim returns the registered device token", Boolean(claimedForA), `${(claim.data ?? []).length} claimed`);

  if (claimedForA) {
    const sent = await admin.rpc("complete_notification_delivery", {
      p_queue_id: claimedForA.queue_id,
      p_success: true,
      p_error: null,
    });
    check("push: successful delivery recorded", !sent.error, sent.error?.message);
    const { data: sentRow } = await admin
      .from("notification_delivery_queue")
      .select("status, sent_at")
      .eq("id", claimedForA.queue_id)
      .single();
    check("push: sent status persisted", sentRow?.status === "sent" && Boolean(sentRow?.sent_at));
  }

  const removal = await playerAClient.rpc("remove_device_token", { p_token: token });
  check("push: owner removes device token", !removal.error && removal.data === true, removal.error?.message);
  const revoked = await admin.from("device_tokens").select("revoked_at").eq("token", token).single();
  check("push: removed token is revoked, not deleted", Boolean(revoked.data?.revoked_at));

  // Register a new device token for retry probe test (since previous token was revoked)
  const retryToken = `phase5-retry-${run}-${"x".repeat(20)}`;
  const retryReg = await playerAClient.rpc("register_device_token", {
    p_token: retryToken,
    p_platform: "android",
    p_device_name: "Retry probe device",
  });
  check("push: retry probe device token registered", !retryReg.error && Boolean(retryReg.data), retryReg.error?.message);

  // Retry/dead-letter semantics are exercised directly on a synthetic queue row.
  const { data: retryNotification } = await admin
    .from("notifications")
    .insert({
      user_id: playerA.id,
      type: "phase5_retry_probe",
      title: "Retry probe",
      body: "Retry probe",
      category: "system",
      push_requested: true,
    })
    .select("id")
    .single();
  // With per-device queue, pick the first queue row for this notification
  const { data: retryQueues } = await admin
    .from("notification_delivery_queue")
    .select("id")
    .eq("notification_id", retryNotification.id)
    .limit(1);
  const retryQueue = (retryQueues ?? [])[0];
  if (retryQueue) {
    await admin.from("notification_delivery_queue").update({ attempts: 2 }).eq("id", retryQueue.id);
    await admin.rpc("complete_notification_delivery", {
      p_queue_id: retryQueue.id,
      p_success: false,
      p_error: "transient FCM failure",
    });
    const { data: failedRow } = await admin
      .from("notification_delivery_queue")
      .select("status, last_error, next_attempt_at")
      .eq("id", retryQueue.id)
      .single();
    check(
      "push: failures are retried with backoff",
      failedRow?.status === "failed" && failedRow?.last_error === "transient FCM failure" && Boolean(failedRow?.next_attempt_at)
    );

    await admin.from("notification_delivery_queue").update({ attempts: 5 }).eq("id", retryQueue.id);
    await admin.rpc("complete_notification_delivery", {
      p_queue_id: retryQueue.id,
      p_success: false,
      p_error: "permanent failure",
    });
    const { data: deadRow } = await admin
      .from("notification_delivery_queue")
      .select("status")
      .eq("id", retryQueue.id)
      .single();
    check("push: exhausted retries become dead letters", deadRow?.status === "dead");
  } else {
    check("push: retry probe queue row exists", false);
  }

  // Clean up retry token
  await playerAClient.rpc("remove_device_token", { p_token: retryToken });

  // -------------------------------------------------------- admin authorization
  await expectFailure(
    "admin: ordinary user cannot search users",
    outsiderClient.rpc("admin_search_users", { p_query: "player" }),
    ["NOT_PLATFORM_ADMIN", "42501"]
  );
  await expectFailure(
    "admin: ordinary user cannot read metrics",
    outsiderClient.rpc("admin_platform_metrics"),
    ["NOT_PLATFORM_ADMIN", "42501"]
  );
  await expectFailure(
    "admin: ordinary user cannot self-assign platform admin",
    outsiderClient.from("platform_admins").insert({ user_id: outsider.id, role: "super_admin" }),
    ["permission denied", "42501"]
  );
  await expectFailure(
    "admin: ordinary user cannot update platform admins",
    outsiderClient.from("platform_admins").update({ role: "super_admin" }).eq("user_id", outsider.id),
    ["permission denied", "42501"]
  );

  const search = await adminClient.rpc("admin_search_users", { p_query: playerA.email });
  check("admin: search returns matching user", !search.error && (search.data ?? []).some((u) => u.user_id === playerA.id), search.error?.message);

  const inspect = await adminClient.rpc("admin_get_user", { p_user_id: playerA.id });
  check(
    "admin: inspection returns private account detail",
    !inspect.error && inspect.data?.profile?.email === playerA.email.toLowerCase() && inspect.data?.profile?.account_status === "active",
    inspect.error?.message ?? JSON.stringify(inspect.data?.profile)
  );

  const suspend = await adminClient.rpc("admin_suspend_user", {
    p_user_id: playerB.id,
    p_reason: "Phase 5 automated suspension",
  });
  check("admin: user suspension succeeds", !suspend.error, suspend.error?.message);
  const status = await adminClient.rpc("account_status", { p_user_id: playerB.id });
  check("admin: suspended status persisted", status.data === "suspended", JSON.stringify(status.error ?? status.data));
  const active = await adminClient.rpc("is_account_active", { p_user_id: playerB.id });
  check("admin: suspended account is inactive", active.data === false, JSON.stringify(active.error ?? active.data));

  const auditCount = await scalarCount("audit_logs", (row) => row.action === "user.suspended" && row.resource_id === playerB.id);
  check("admin: suspension is written to the audit log", auditCount === 1, `${auditCount} audit rows`);

  await expectFailure(
    "admin: suspended user cannot submit abuse reports",
    playerBClient.rpc("submit_abuse_report", {
      p_category: "spam",
      p_subject_type: "other",
      p_description: "Suspended user attempt with enough text.",
    }),
    ["ACCOUNT_INACTIVE", "42501"]
  );

  await expectFailure(
    "admin: cannot suspend self",
    adminClient.rpc("admin_suspend_user", { p_user_id: adminUser.id, p_reason: "self" }),
    ["CANNOT_SUSPEND_SELF"]
  );

  const restore = await adminClient.rpc("admin_restore_user", { p_user_id: playerB.id });
  check("admin: user restore succeeds", !restore.error, restore.error?.message);
  const activeAgain = await adminClient.rpc("is_account_active", { p_user_id: playerB.id });
  check("admin: restored account is active", activeAgain.data === true, JSON.stringify(activeAgain.error ?? activeAgain.data));

  // -------------------------------------------------------- organizer approval
  const request = await organizerClient.rpc("request_organizer_account", {
    p_organization_name: `Org ${run}`,
    p_contact_note: "Automated Phase 5 request",
  });
  check("organizer approval: request created", !request.error, request.error?.message);
  const listed = await adminClient.rpc("admin_list_organizers", { p_status: "pending" });
  check("organizer approval: pending request visible to admin", (listed.data ?? []).some((o) => o.user_id === organizer.id), listed.error?.message);

  const flagOn = await adminClient.rpc("admin_set_platform_setting", {
    p_key: "organizer_approval_required",
    p_value: true,
    p_is_public: true,
    p_description: "Phase 5 test enforcement",
  });
  check("settings: admin updates feature flag", !flagOn.error, flagOn.error?.message);

  await expectFailure(
    "organizer approval: unapproved organizer cannot create tournament",
    organizerClient.rpc("create_tournament", { p_payload: tournamentPayload({ title: `Blocked ${run}` }) }),
    ["ORGANIZER_NOT_APPROVED", "42501"]
  );

  const approve = await adminClient.rpc("admin_set_organizer_status", {
    p_user_id: organizer.id,
    p_status: "approved",
  });
  check("organizer approval: admin approves organizer", !approve.error, approve.error?.message);
  const { data: approvedTournament, error: approvedError } = await organizerClient.rpc("create_tournament", {
    p_payload: tournamentPayload({ title: `Approved ${run}` }),
  });
  check("organizer approval: approved organizer can create tournament", !approvedError && Boolean(approvedTournament), approvedError?.message);

  await adminClient.rpc("admin_set_platform_setting", {
    p_key: "organizer_approval_required",
    p_value: false,
    p_is_public: true,
  });

  // -------------------------------------------------------- abuse reporting
  const { data: reportId, error: reportError } = await playerAClient.rpc("submit_abuse_report", {
    p_category: "cheating",
    p_subject_type: "tournament",
    p_tournament_id: tournamentId,
    p_description: "Automated Phase 5 abuse report with sufficient detail.",
    p_evidence_paths: [],
  });
  check("abuse: reporter submits report", !reportError && Boolean(reportId), reportError?.message);

  const ownReports = await playerAClient.from("abuse_reports").select("id, reporter_id, status");
  check("abuse: reporter reads own report", (ownReports.data ?? []).some((r) => r.id === reportId), ownReports.error?.message);

  const otherReports = await outsiderClient.from("abuse_reports").select("id, reporter_id");
  check(
    "abuse: unrelated user cannot read the report",
    (otherReports.data ?? []).every((r) => r.reporter_id === outsider.id) && !(otherReports.data ?? []).some((r) => r.id === reportId),
    otherReports.error?.message
  );

  const adminReports = await adminClient.from("abuse_reports").select("id, reporter_id").eq("id", reportId);
  check("abuse: admin reads all reports", (adminReports.data ?? []).some((r) => r.id === reportId), adminReports.error?.message);

  await expectFailure(
    "abuse: reporter cannot update report status directly",
    playerAClient.from("abuse_reports").update({ status: "resolved" }).eq("id", reportId),
    ["permission denied", "42501"]
  );

  const triage = await adminClient.rpc("admin_triage_abuse_report", {
    p_report_id: reportId,
    p_status: "investigating",
    p_severity: "high",
    p_assigned_admin_id: adminUser.id,
    p_note: "Assigned for investigation",
  });
  check("abuse: admin triages and assigns report", !triage.error, triage.error?.message);

  const resolve = await adminClient.rpc("admin_resolve_abuse_report", {
    p_report_id: reportId,
    p_resolution: "Evidence reviewed; report upheld.",
  });
  check("abuse: admin resolves report", !resolve.error, resolve.error?.message);

  const events = await playerAClient
    .from("abuse_report_events")
    .select("event_type, from_status, to_status, note")
    .eq("report_id", reportId)
    .order("created_at");
  check(
    "abuse: reporter sees complete audit history",
    (events.data ?? []).some((e) => e.event_type === "submitted") &&
      (events.data ?? []).some((e) => e.event_type === "status_changed") &&
      (events.data ?? []).some((e) => e.event_type === "resolved"),
    events.error?.message ?? JSON.stringify(events.data)
  );

  const outsiderEvents = await outsiderClient
    .from("abuse_report_events")
    .select("id")
    .eq("report_id", reportId);
  check("abuse: unrelated user cannot read report history", (outsiderEvents.data ?? []).length === 0, outsiderEvents.error?.message);

  const aRowsResolved = await notificationsFor(playerAClient);
  check("abuse: reporter notified on resolution", hasType(aRowsResolved, "abuse_report_resolved"));
  const adminNotified = (await notificationsFor(adminClient)).filter((r) => r.type === "abuse_report_submitted");
  check("abuse: admins notified on submission", adminNotified.length > 0, `${adminNotified.length} admin notifications`);

  // -------------------------------------------------------- moderator scope
  const moderateTournament = await createOpenTournament(organizerClient, { max_teams: 4 });
  await registerSolo(playerAClient, moderateTournament);
  const assign = await adminClient.rpc("admin_assign_moderator", {
    p_tournament_id: moderateTournament,
    p_user_id: outsider.id,
  });
  check("moderation: admin assigns moderator", !assign.error, assign.error?.message);

  const isOrg = await outsiderClient.rpc("is_tournament_organizer", {
    p_tournament_id: moderateTournament,
    p_user_id: outsider.id,
  });
  check("moderation: moderator scoped to assigned tournament", isOrg.data === true, isOrg.error?.message);

  const otherTournament = await createOpenTournament(organizerClient, { max_teams: 4 });
  const isOtherOrg = await outsiderClient.rpc("is_tournament_organizer", {
    p_tournament_id: otherTournament,
    p_user_id: outsider.id,
  });
  check("moderation: moderator has no scope over other tournaments", isOtherOrg.data === false, isOtherOrg.error?.message);

  await expectFailure(
    "moderation: moderator cannot assign other moderators",
    outsiderClient.rpc("admin_assign_moderator", {
      p_tournament_id: otherTournament,
      p_user_id: outsider.id,
    }),
    ["NOT_PLATFORM_ADMIN", "42501"]
  );

  await expectFailure(
    "moderation: participant cannot be assigned to moderate own tournament",
    adminClient.rpc("admin_assign_moderator", {
      p_tournament_id: moderateTournament,
      p_user_id: playerA.id,
    }),
    ["MODERATOR_PARTICIPATES_IN_TOURNAMENT", "42501"]
  );

  const moderatorList = await adminClient.rpc("admin_list_moderators", { p_tournament_id: moderateTournament });
  check("moderation: admin lists assigned moderators", (moderatorList.data ?? []).some((m) => m.user_id === outsider.id), moderatorList.error?.message);

  const removed = await adminClient.rpc("admin_remove_moderator", {
    p_tournament_id: moderateTournament,
    p_user_id: outsider.id,
  });
  check("moderation: admin removes moderator", !removed.error && removed.data === true, removed.error?.message);

  // -------------------------------------------------------- audit logs
  const ownAudit = await outsiderClient.from("audit_logs").select("id, user_id, action");
  check(
    "audit: ordinary user only sees own entries",
    (ownAudit.data ?? []).every((a) => a.user_id === outsider.id),
    ownAudit.error?.message
  );

  const auditSearch = await adminClient.rpc("admin_search_audit_logs", {
    p_action: "user.suspended",
    p_limit: 10,
  });
  check("audit: admin searches audit logs", (auditSearch.data ?? []).some((a) => a.resource_id === playerB.id), auditSearch.error?.message);

  // -------------------------------------------------------- settings + metrics
  await expectFailure(
    "settings: ordinary user cannot change settings",
    outsiderClient.rpc("admin_set_platform_setting", {
      p_key: "abuse_reporting_enabled",
      p_value: false,
      p_is_public: true,
    }),
    ["NOT_PLATFORM_ADMIN", "42501"]
  );

  await adminClient.rpc("admin_set_platform_setting", {
    p_key: "phase5.private_probe",
    p_value: { secret: `probe-${run}` },
    p_is_public: false,
    p_description: "Private Phase 5 probe",
  });
  const publicSettings = await outsiderClient.from("platform_settings").select("key, value, is_public");
  check(
    "settings: clients cannot read private settings",
    !(publicSettings.data ?? []).some((s) => s.key === "phase5.private_probe") &&
      (publicSettings.data ?? []).some((s) => s.key === "abuse_reporting_enabled"),
    publicSettings.error?.message
  );
  const allSettings = await adminClient.from("platform_settings").select("key").eq("key", "phase5.private_probe");
  check("settings: admins read private settings", (allSettings.data ?? []).length === 1, allSettings.error?.message);

  const metrics = await adminClient.rpc("admin_platform_metrics");
  check(
    "metrics: operational snapshot available",
    !metrics.error &&
      typeof metrics.data?.users?.total === "number" &&
      typeof metrics.data?.abuse_reports?.open === "number" &&
      typeof metrics.data?.notifications?.push_pending === "number",
    metrics.error?.message ?? JSON.stringify(metrics.data)
  );

  const tournamentOversight = await adminClient.rpc("admin_list_tournaments", { p_query: run });
  check("oversight: admin lists tournaments", !tournamentOversight.error && (tournamentOversight.data ?? []).length > 0, tournamentOversight.error?.message);

  // -------------------------------------------------------- admin provisioning
  const grantSupport = await adminClient.rpc("admin_grant_platform_admin", {
    p_user_id: supportUser.id,
    p_role: "support",
    p_notes: "Phase 5 support probe",
  });
  check("admin provisioning: super admin grants support role", !grantSupport.error, grantSupport.error?.message);

  const supportClient = await signIn(supportUser);
  const supportMetrics = await supportClient.rpc("admin_platform_metrics");
  check("admin provisioning: support role can read metrics", !supportMetrics.error, supportMetrics.error?.message);
  await expectFailure(
    "admin provisioning: support role cannot suspend users",
    supportClient.rpc("admin_suspend_user", { p_user_id: playerB.id, p_reason: "support attempt" }),
    ["INSUFFICIENT_ADMIN_ROLE", "42501"]
  );
  await expectFailure(
    "admin provisioning: non-super admin cannot grant admin roles",
    supportClient.rpc("admin_grant_platform_admin", { p_user_id: outsider.id, p_role: "admin" }),
    ["INSUFFICIENT_ADMIN_ROLE", "42501"]
  );

  const revokeSelf = await adminClient.rpc("admin_revoke_platform_admin", { p_user_id: adminUser.id });
  check("admin provisioning: cannot revoke own super admin", Boolean(revokeSelf.error), revokeSelf.error?.message);

  const revokeSupport = await adminClient.rpc("admin_revoke_platform_admin", {
    p_user_id: supportUser.id,
    p_note: "Phase 5 probe complete",
  });
  check("admin provisioning: super admin revokes role", !revokeSupport.error, revokeSupport.error?.message);
  await expectFailure(
    "admin provisioning: revoked admin loses access",
    supportClient.rpc("admin_platform_metrics"),
    ["NOT_PLATFORM_ADMIN", "42501"]
  );

  // -------------------------------------------------------- anonymous access
  await expectFailure(
    "anon: cannot read notifications",
    anonClient.from("notifications").select("id"),
    ["permission denied", "JWT", "42501"]
  );
  await expectFailure(
    "anon: cannot call admin RPC",
    anonClient.rpc("admin_platform_metrics"),
    ["permission denied", "JWT", "NOT_PLATFORM_ADMIN", "42501", "AUTH_REQUIRED"]
  );

  console.log(`\nPhase 5 database verification: ${passed} PASS, ${failed} FAIL, ${blocked} BLOCKED`);
  if (failed > 0 || blocked > 0) process.exitCode = 1;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
