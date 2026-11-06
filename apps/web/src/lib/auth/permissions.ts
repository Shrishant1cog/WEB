export type PlatformRole = "player" | "organizer" | "moderator" | "administrator" | null;

export type OrganizerRole = "owner" | "admin" | "staff" | null;

export interface UserPermissions {
  platformRole: PlatformRole;
  organizerMemberships: Array<{
    tournamentId: string;
    role: OrganizerRole;
  }>;
}

export async function getUserPermissions(
  supabase: ReturnType<typeof createServerSupabaseClient>,
  userId: string
): Promise<UserPermissions> {
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

  return {
    platformRole: (profile?.platform_role as PlatformRole) || "player",
    organizerMemberships:
      profile?.organizer_memberships?.map((m: any) => ({
        tournamentId: m.tournament_id,
        role: m.role as OrganizerRole,
      })) || [],
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

export async function getUserRole(
  supabase: ReturnType<typeof createServerSupabaseClient>,
  userId: string
): Promise<PlatformRole> {
  const { data: profile } = await supabase
    .from("profiles")
    .select("platform_role")
    .eq("id", userId)
    .single();

  return (profile?.platform_role as PlatformRole) || "player";
}