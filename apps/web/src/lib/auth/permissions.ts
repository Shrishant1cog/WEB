import { createServerSupabaseClient } from "@/lib/supabase/client";

/**
 * Roles are scope-based (see docs/PRODUCT_REQUIREMENTS.md §2):
 * a player is simply an authenticated user; an organizer is someone who
 * owns or is a member of a tournament organizing team. Platform-wide admin
 * roles are Phase 5 scope and are intentionally not modelled here yet.
 */
export type PlatformRole = "player" | "organizer" | null;

export type OrganizerRole = "owner" | "organizer" | "moderator" | null;

export interface OrganizerMembership {
  tournamentId: string;
  role: OrganizerRole;
}

export interface UserPermissions {
  userId: string;
  platformRole: PlatformRole;
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
    organizerMemberships,
  };
}

export function hasOrganizerAccess(
  permissions: UserPermissions,
  tournamentId?: string
): boolean {
  if (permissions.organizerMemberships.length === 0) return false;
  if (!tournamentId) return true;
  return permissions.organizerMemberships.some((m) => m.tournamentId === tournamentId);
}

/**
 * Platform administration is Phase 5 scope. Until an explicit admin role
 * model exists, nobody is treated as a platform administrator.
 */
export function hasAdminAccess(_permissions: UserPermissions): boolean {
  return false;
}

export function hasModeratorAccess(permissions: UserPermissions): boolean {
  return permissions.organizerMemberships.some((m) => m.role === "moderator");
}

export async function getUserRole(userId: string): Promise<PlatformRole> {
  const permissions = await getUserPermissions(userId);
  return permissions.platformRole;
}
