"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { humanizeDbError } from "@/lib/errors";
import { firstIssue, inviteInputSchema, teamInputSchema } from "@/lib/validation/tournament";

export type TeamActionState = {
  error?: string;
  success?: string;
  inviteToken?: string;
  inviteEmail?: string;
} | null;

async function currentUser() {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return { supabase, user };
}

export async function createTeamAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const parsed = teamInputSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { error: firstIssue(parsed.error) };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in to create a team." };

  const { data, error } = await supabase.rpc("create_team", {
    p_name: parsed.data.name,
    p_tag: parsed.data.tag ?? null,
    p_description: parsed.data.description ?? null,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/my-teams");
  redirect(`/my-teams/${data}`);
}

export async function inviteToTeamAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const teamId = String(formData.get("teamId") ?? "");
  if (!teamId) return { error: "Missing team." };

  const parsed = inviteInputSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { error: firstIssue(parsed.error) };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { data, error } = await supabase.rpc("invite_to_team", {
    p_team_id: teamId,
    p_invited_user_id: parsed.data.invitedUserId ?? null,
    p_email: parsed.data.email ?? null,
    p_expires_hours: parsed.data.expiresHours,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/my-teams/${teamId}`);
  return {
    success: "Invitation created. Share this single-use link with the player.",
    inviteToken: data as string,
    inviteEmail: parsed.data.email,
  };
}

export async function acceptInvitationAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const token = String(formData.get("token") ?? "");
  if (!token) return { error: "Missing invitation token." };

  const { supabase, user } = await currentUser();
  if (!user) {
    redirect(`/login?redirect=${encodeURIComponent(`/team/invite/${token}`)}`);
  }

  const { data, error } = await supabase.rpc("accept_team_invitation", { p_token: token });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/my-teams");
  redirect(`/my-teams/${data}?joined=1`);
}

export async function declineInvitationAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const token = String(formData.get("token") ?? "");
  if (!token) return { error: "Missing invitation token." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("decline_team_invitation", { p_token: token });
  if (error) return { error: humanizeDbError(error) };

  redirect("/my-teams?declined=1");
}

export async function revokeInvitationAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const invitationId = String(formData.get("invitationId") ?? "");
  const teamId = String(formData.get("teamId") ?? "");
  if (!invitationId) return { error: "Missing invitation." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("revoke_team_invitation", {
    p_invitation_id: invitationId,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/my-teams/${teamId}`);
  return { success: "Invitation revoked." };
}

export async function removeTeamMemberAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const teamId = String(formData.get("teamId") ?? "");
  const userId = String(formData.get("userId") ?? "");
  if (!teamId || !userId) return { error: "Missing team member." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("remove_team_member", {
    p_team_id: teamId,
    p_user_id: userId,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/my-teams/${teamId}`);
  redirect(`/my-teams/${teamId}?memberRemoved=1`);
}

export async function transferCaptaincyAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const teamId = String(formData.get("teamId") ?? "");
  const newCaptain = String(formData.get("newCaptain") ?? "");
  if (!teamId || !newCaptain) return { error: "Choose a team member." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("transfer_team_captaincy", {
    p_team_id: teamId,
    p_new_captain: newCaptain,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath(`/my-teams/${teamId}`);
  redirect(`/my-teams/${teamId}?captainTransferred=1`);
}

export async function leaveTeamAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const teamId = String(formData.get("teamId") ?? "");
  if (!teamId) return { error: "Missing team." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("leave_team", { p_team_id: teamId });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/my-teams");
  redirect("/my-teams?left=1");
}

export async function dissolveTeamAction(
  _prev: TeamActionState,
  formData: FormData
): Promise<TeamActionState> {
  const teamId = String(formData.get("teamId") ?? "");
  if (!teamId) return { error: "Missing team." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in." };

  const { error } = await supabase.rpc("dissolve_team", { p_team_id: teamId });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/my-teams");
  redirect("/my-teams?dissolved=1");
}
