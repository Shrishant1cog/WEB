import { createServerSupabaseClient } from "@/lib/supabase/client";

export type PlatformRole = "player" | "organizer" | "moderator" | "administrator" | null;

export type OrganizerRole = "owner" | "admin" | "staff" | null;

export interface UserPermissions {
  platformRole: PlatformRole;
  organizerMemberships: Array<{
    tournamentId: string;
    role: OrganizerRole;
  }>;
}

export async function getUserPermissions(userId: string): Promise<UserPermissions> {
  const supabase = await createServerSupabaseClient();
  const { data: profile } = await supabase
    .from("profiles")
    .select(
      `
      platform_role,
      organizer_memberships (
        tournament_id,
        role
      )
    `
    )
    .eq("id", userId)
    .single();

  const platformRole = (profile as any)?.platform_role as PlatformRole;
  const organizerMemberships = (profile as any)?.organizer_memberships?.map((m: any) => ({
    tournamentId: m.tournament_id,
    role: m.role as OrganizerRole,
  })) || [];

  return {
    platformRole: platformRole || "player",
    organizerMemberships,
  };
}

export function hasOrganizerAccess(
  permissions: UserPermissions,
  tournamentId?: string
): boolean {
  if (
    permissions.platformRole === "administrator" ||
    permissions.platformRole === "moderator"
  ) {
    return true;
  }

  if (permissions.platformRole === "organizer") {
    if (!tournamentId) return true; // Has organizer role, can access dashboard
    return permissions.organizerMemberships.some(
      (m) => m.tournamentId === tournamentId
    );
  }

  return false;
}

export function hasAdminAccess(permissions: UserPermissions): boolean {
  return permissions.platformRole === "administrator";
}

export function hasModeratorAccess(permissions: UserPermissions): boolean {
  return (
    permissions.platformRole === "administrator" ||
    permissions.platformRole === "moderator"
  );
}

export async function getUserRole(userId: string): Promise<PlatformRole> {
  const supabase = await createServerSupabaseClient();
  const { data: profile } = await supabase
    .from("profiles")
    .select("platform_role")
    .eq("id", userId)
    .single();

  return (profile as any)?.platform_role as PlatformRole || "player";
}