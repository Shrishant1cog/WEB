"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import type { Json } from "@/types/supabase";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { humanizeDbError } from "@/lib/errors";
import {
  firstIssue,
  tournamentInputSchema,
  toTournamentPayload,
  tournamentStatusSchema,
} from "@/lib/validation/tournament";

export type ActionState = { error?: string; success?: string } | null;

async function currentUser() {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return { supabase, user };
}

export async function createTournamentAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const parsed = tournamentInputSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { error: firstIssue(parsed.error) };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in to create a tournament." };

  const { data, error } = await supabase.rpc("create_tournament", {
    p_payload: toTournamentPayload(parsed.data) as unknown as Json,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/organizer/dashboard");
  revalidatePath("/tournaments");
  redirect(`/organizer/tournaments/${data}`);
}

export async function updateTournamentAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const tournamentId = String(formData.get("tournamentId") ?? "");
  if (!tournamentId) return { error: "Missing tournament." };

  const parsed = tournamentInputSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { error: firstIssue(parsed.error) };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("update_tournament", {
    p_tournament_id: tournamentId,
    p_payload: toTournamentPayload(parsed.data) as unknown as Json,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/organizer/tournaments/${tournamentId}`);
  revalidatePath(`/tournaments/${tournamentId}`);
  redirect(`/organizer/tournaments/${tournamentId}?updated=1`);
}

export async function setTournamentStatusAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const parsedStatus = tournamentStatusSchema.safeParse(formData.get("status"));
  const reason = String(formData.get("reason") ?? "") || null;

  if (!tournamentId) return { error: "Missing tournament." };
  if (!parsedStatus.success) return { error: "Invalid status." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("set_tournament_status", {
    p_tournament_id: tournamentId,
    p_status: parsedStatus.data,
    p_reason: reason,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/organizer/tournaments/${tournamentId}`);
  revalidatePath("/organizer/dashboard");
  revalidatePath("/tournaments");
  revalidatePath(`/tournaments/${tournamentId}`);
  redirect(`/organizer/tournaments/${tournamentId}?status=${parsedStatus.data}`);
}

export async function registerTournamentAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const teamIdRaw = String(formData.get("teamId") ?? "");
  const teamId = teamIdRaw === "" ? null : teamIdRaw;

  if (!tournamentId) return { error: "Missing tournament." };

  const { supabase, user } = await currentUser();
  if (!user) {
    redirect(`/login?redirect=${encodeURIComponent(`/tournaments/${tournamentId}`)}`);
  }

  const { data, error } = await supabase.rpc("register_tournament_entry", {
    p_tournament_id: tournamentId,
    p_team_id: teamId,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/tournaments/${tournamentId}`);
  revalidatePath("/my-tournaments");
  revalidatePath("/organizer/dashboard");

  const result = data as { status?: string; waitlist_position?: number | null } | null;
  const query =
    result?.status === "waitlisted"
      ? `registered=waitlisted&position=${result.waitlist_position ?? ""}`
      : "registered=confirmed";
  redirect(`/tournaments/${tournamentId}?${query}`);
}

export async function promoteWaitlistAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const tournamentId = String(formData.get("tournamentId") ?? "");
  if (!tournamentId) return { error: "Missing tournament." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { data, error } = await supabase.rpc("organizer_promote_waitlist", {
    p_tournament_id: tournamentId,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/organizer/tournaments/${tournamentId}`);
  return data
    ? { success: "The next waitlisted entry has been confirmed." }
    : { error: "No waitlisted entry could be promoted (tournament is full or waitlist is empty)." };
}

export async function withdrawRegistrationAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const entryId = String(formData.get("entryId") ?? "");
  const tournamentId = String(formData.get("tournamentId") ?? "");
  if (!entryId) return { error: "Missing registration." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("withdraw_tournament_entry", {
    p_entry_id: entryId,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/tournaments/${tournamentId}`);
  revalidatePath("/my-tournaments");
  redirect("/my-tournaments?withdrawn=1");
}
