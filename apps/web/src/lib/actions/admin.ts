"use server";

import { revalidatePath } from "next/cache";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { getPlatformAdminRole, type PlatformAdminRole } from "@/lib/auth/permissions";
import { humanizeDbError } from "@/lib/errors";

export type ActionState = { error?: string; success?: string } | null;

const RANK: Record<Exclude<PlatformAdminRole, null>, number> = {
  support: 1,
  admin: 2,
  super_admin: 3,
};

async function requireAdmin(minimum: Exclude<PlatformAdminRole, null>) {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { supabase, user: null as null, error: "Please sign in to continue." };

  const role = await getPlatformAdminRole();
  if (!role || RANK[role] < RANK[minimum]) {
    return { supabase, user: null as null, error: "You do not have permission to do that." };
  }
  return { supabase, user, error: null as null };
}

function text(formData: FormData, key: string): string {
  return String(formData.get(key) ?? "").trim();
}

export async function suspendUserAction(_prev: ActionState, formData: FormData): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const userId = text(formData, "userId");
  const reason = text(formData, "reason");
  if (!userId) return { error: "User not found." };
  if (reason.length < 3) return { error: "Provide a suspension reason." };

  const result = await supabase.rpc("admin_suspend_user", {
    p_user_id: userId,
    p_reason: reason,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath(`/admin/users/${userId}`);
  revalidatePath("/admin/users");
  revalidatePath("/admin");
  return { success: "User suspended." };
}

export async function restoreUserAction(_prev: ActionState, formData: FormData): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const userId = text(formData, "userId");
  if (!userId) return { error: "User not found." };

  const result = await supabase.rpc("admin_restore_user", {
    p_user_id: userId,
    p_note: text(formData, "note") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath(`/admin/users/${userId}`);
  revalidatePath("/admin/users");
  revalidatePath("/admin");
  return { success: "User restored." };
}

export async function setOrganizerStatusAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const userId = text(formData, "userId");
  const status = text(formData, "status");
  if (!userId) return { error: "User not found." };
  if (!["pending", "approved", "suspended"].includes(status)) {
    return { error: "That organizer status is not valid." };
  }

  const result = await supabase.rpc("admin_set_organizer_status", {
    p_user_id: userId,
    p_status: status,
    p_reason: text(formData, "reason") || null,
    p_organization_name: text(formData, "organizationName") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/admin/organizers");
  revalidatePath(`/admin/users/${userId}`);
  return { success: `Organizer status set to ${status}.` };
}

export async function setPlatformSettingAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const key = text(formData, "key");
  const rawValue = text(formData, "value");
  const kind = text(formData, "kind") || "boolean";
  if (!key) return { error: "Setting key is required." };

  let value: unknown;
  try {
    if (kind === "boolean") {
      value = rawValue === "true" || rawValue === "on";
    } else if (kind === "number") {
      value = Number(rawValue);
    } else {
      value = JSON.parse(rawValue);
    }
  } catch {
    return { error: "Setting value is not valid JSON." };
  }

  const result = await supabase.rpc("admin_set_platform_setting", {
    p_key: key,
    p_value: value as never,
    p_is_public: formData.get("isPublic") === "on",
    p_description: text(formData, "description") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/admin/settings");
  return { success: `Setting ${key} saved.` };
}

export async function assignModeratorAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const tournamentId = text(formData, "tournamentId");
  const userId = text(formData, "userId");
  if (!tournamentId || !userId) return { error: "Tournament and user are required." };

  const result = await supabase.rpc("admin_assign_moderator", {
    p_tournament_id: tournamentId,
    p_user_id: userId,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/admin/tournaments");
  return { success: "Moderator assigned." };
}

export async function removeModeratorAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const tournamentId = text(formData, "tournamentId");
  const userId = text(formData, "userId");
  if (!tournamentId || !userId) return { error: "Tournament and user are required." };

  const result = await supabase.rpc("admin_remove_moderator", {
    p_tournament_id: tournamentId,
    p_user_id: userId,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/admin/tournaments");
  return { success: "Moderator removed." };
}

export async function triageReportAction(_prev: ActionState, formData: FormData): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("support");
  if (!user) return { error: error ?? "Not permitted." };

  const reportId = text(formData, "reportId");
  const status = text(formData, "status");
  if (!reportId) return { error: "Report not found." };

  const result = await supabase.rpc("admin_triage_abuse_report", {
    p_report_id: reportId,
    p_status: status,
    p_severity: text(formData, "severity") || null,
    p_assigned_admin_id: text(formData, "assignedAdminId") || null,
    p_note: text(formData, "note") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/admin/reports");
  revalidatePath(`/admin/reports/${reportId}`);
  return { success: "Report updated." };
}

export async function resolveReportAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("admin");
  if (!user) return { error: error ?? "Not permitted." };

  const reportId = text(formData, "reportId");
  const resolution = text(formData, "resolution");
  if (!reportId) return { error: "Report not found." };
  if (resolution.length < 5) return { error: "Provide a resolution of at least 5 characters." };

  const result = await supabase.rpc("admin_resolve_abuse_report", {
    p_report_id: reportId,
    p_resolution: resolution,
    p_dismiss: formData.get("dismiss") === "on",
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/admin/reports");
  revalidatePath(`/admin/reports/${reportId}`);
  return { success: "Report resolved." };
}

export async function grantPlatformAdminAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("super_admin");
  if (!user) return { error: error ?? "Not permitted." };

  const userId = text(formData, "userId");
  const role = text(formData, "role");
  if (!userId) return { error: "User not found." };
  if (!["super_admin", "admin", "support"].includes(role)) {
    return { error: "That administrator role is not valid." };
  }

  const result = await supabase.rpc("admin_grant_platform_admin", {
    p_user_id: userId,
    p_role: role,
    p_notes: text(formData, "notes") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath(`/admin/users/${userId}`);
  revalidatePath("/admin/settings");
  return { success: `Administrator role ${role} granted.` };
}

export async function revokePlatformAdminAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user, error } = await requireAdmin("super_admin");
  if (!user) return { error: error ?? "Not permitted." };

  const userId = text(formData, "userId");
  if (!userId) return { error: "User not found." };

  const result = await supabase.rpc("admin_revoke_platform_admin", {
    p_user_id: userId,
    p_note: text(formData, "note") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath(`/admin/users/${userId}`);
  revalidatePath("/admin/settings");
  return { success: "Administrator role revoked." };
}

export async function requestOrganizerAccountAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Please sign in to continue." };

  const result = await supabase.rpc("request_organizer_account", {
    p_organization_name: text(formData, "organizationName") || null,
    p_contact_note: text(formData, "contactNote") || null,
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath("/organizer/dashboard");
  return { success: "Organizer request submitted for review." };
}

export async function createAnnouncementAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Please sign in to continue." };

  const tournamentId = text(formData, "tournamentId");
  const title = text(formData, "title");
  const body = text(formData, "body");
  if (!tournamentId) return { error: "Tournament not found." };
  if (title.length < 1 || title.length > 120) return { error: "Title must be 1-120 characters." };
  if (body.length < 1 || body.length > 4000) return { error: "Body must be 1-4000 characters." };

  const result = await supabase.rpc("create_tournament_announcement", {
    p_tournament_id: tournamentId,
    p_title: title,
    p_body: body,
    p_pinned: formData.get("pinned") === "on",
  });
  if (result.error) return { error: humanizeDbError(result.error) };

  revalidatePath(`/organizer/tournaments/${tournamentId}`);
  revalidatePath(`/organizer/tournaments/${tournamentId}/announcements`);
  return { success: "Announcement published." };
}
