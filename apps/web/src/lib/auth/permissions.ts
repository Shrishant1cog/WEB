import { createServerSupabaseClient } from "@/lib/supabase/client";

/**
 * Roles are scope-based (see docs/PRODUCT_REQUIREMENTS.md §2):
 * a player is simply an authenticated user; an organizer is someone who
 * owns or is a member of a tournament organizing team. Platform-wide admin
 * roles live in the `platform_admins` table and are always resolved on the
 * server — never from client-supplied data.
 */
export type PlatformRole = "player" | "organizer" | null;

export type PlatformAdminRole = "super_admin" | "admin" | "support" | null;

export type OrganizerRole = "owner" | "organizer" | "moderator" | null;

export interface OrganizerMembership {
  tournamentId: string;
  role: OrganizerRole;
}

export interface UserPermissions {
  userId: string;
  platformRole: PlatformRole;
  platformAdminRole: PlatformAdminRole;
  organizerMemberships: OrganizerMembership[];
}

export async function getUserPermissions(userId: string): Promise<UserPermissions> {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("tournament_organizers")
    .select("tournament_id, role")
    .eq("user_id", userId);

  const organizerMemberships: OrganizerMembership[] = (data ?? []).map((row) => ({
    tournamentId: row.tournament_id,
    role: row.role as OrganizerRole,
  }));

  return {
    userId,
    platformRole: organizerMemberships.length > 0 ? "organizer" : "player",
    platformAdminRole: await getPlatformAdminRole(),
    organizerMemberships,
  };
}

/**
 * Resolve the signed-in user's platform administrator role through the
 * SECURITY DEFINER helper. A missing row, a revoked grant or an unauthenticated
 * request all resolve to null.
 */
export async function getPlatformAdminRole(): Promise<PlatformAdminRole> {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data, error } = await supabase.rpc("platform_admin_role", {
    p_user_id: user.id,
  });
  if (error) return null;

  if (data === "super_admin" || data === "admin" || data === "support") {
    return data;
  }
  return null;
}

export async function getAccountStatus(): Promise<string> {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return "anonymous";

  const { data, error } = await supabase.rpc("account_status", {
    p_user_id: user.id,
  });
  if (error) return "active";
  return typeof data === "string" ? data : "active";
}

export function hasOrganizerAccess(
  permissions: UserPermissions,
  tournamentId?: string
): boolean {
  if (permissions.organizerMemberships.length === 0) return false;
  if (!tournamentId) return true;
  return permissions.organizerMemberships.some((m) => m.tournamentId === tournamentId);
}

export function hasAdminAccess(
  permissions: UserPermissions,
  minimum: Exclude<PlatformAdminRole, null> = "support"
): boolean {
  const role = permissions.platformAdminRole;
  if (!role) return false;
  const rank = { support: 1, admin: 2, super_admin: 3 } as const;
  return rank[role] >= rank[minimum];
}

export function hasModeratorAccess(permissions: UserPermissions): boolean {
  return permissions.organizerMemberships.some((m) => m.role === "moderator");
}

export async function getUserRole(userId: string): Promise<PlatformRole> {
  const permissions = await getUserPermissions(userId);
  return permissions.platformRole;
}
