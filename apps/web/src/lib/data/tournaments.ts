import { createServerSupabaseClient } from "@/lib/supabase/client";
import type {
  Profile,
  Team,
  TeamInvitation,
  TeamMember,
  Tournament,
  TournamentEntryMember,
  TournamentListing,
  TournamentRegistration,
} from "@/types/supabase";

const PUBLIC_STATUSES = [
  "published",
  "registration_open",
  "registration_closed",
  "in_progress",
  "completed",
] as const;

export interface TournamentFilters {
  query?: string;
  status?: string;
  mode?: string;
}

export async function getPublicTournaments(
  filters: TournamentFilters = {}
): Promise<TournamentListing[]> {
  const supabase = await createServerSupabaseClient();
  let request = supabase.from("tournament_public_listing").select("*");

  if (filters.query && filters.query.trim() !== "") {
    request = request.ilike("title", `%${filters.query.trim()}%`);
  }
  if (filters.status && filters.status !== "all") {
    request = request.eq("status", filters.status as TournamentListing["status"]);
  } else {
    request = request.in("status", [...PUBLIC_STATUSES]);
  }
  if (filters.mode && filters.mode !== "all") {
    request = request.eq("mode", filters.mode);
  }

  const { data, error } = await request.order("tournament_starts_at", { ascending: true });
  if (error) return [];
  return (data ?? []) as TournamentListing[];
}

export async function getPublicTournament(
  id: string
): Promise<TournamentListing | null> {
  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase
    .from("tournament_public_listing")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) return null;
  return (data as TournamentListing | null) ?? null;
}

export async function getTournamentById(id: string): Promise<Tournament | null> {
  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase
    .from("tournaments")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) return null;
  return data;
}

export async function getOrganizerTournamentIds(userId: string): Promise<string[]> {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("tournament_organizers")
    .select("tournament_id")
    .eq("user_id", userId);
  return (data ?? []).map((row) => row.tournament_id);
}

export async function getOrganizerTournaments(userId: string): Promise<Tournament[]> {
  const ids = await getOrganizerTournamentIds(userId);
  if (ids.length === 0) return [];

  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase
    .from("tournaments")
    .select("*")
    .in("id", ids)
    .is("deleted_at", null)
    .order("created_at", { ascending: false });

  if (error) return [];
  return data ?? [];
}

export async function isOrganizerOf(
  tournamentId: string,
  userId: string
): Promise<boolean> {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("tournament_organizers")
    .select("tournament_id")
    .eq("tournament_id", tournamentId)
    .eq("user_id", userId)
    .maybeSingle();
  return data !== null;
}

export interface RegistrationWithMembers extends TournamentRegistration {
  members: Array<TournamentEntryMember & { profile: Profile | null }>;
}

export async function getTournamentRegistrations(
  tournamentId: string
): Promise<RegistrationWithMembers[]> {
  const supabase = await createServerSupabaseClient();
  const { data: registrationsData, error } = await supabase
    .from("tournament_registrations")
    .select("*")
    .eq("tournament_id", tournamentId)
    .order("status", { ascending: true })
    .order("waitlist_seq", { ascending: true, nullsFirst: false })
    .order("registered_at", { ascending: true });

  if (error || !registrationsData) return [];
  const registrations = registrationsData as TournamentRegistration[];
  if (registrations.length === 0) return [];

  const entryIds = registrations.map((r) => r.id);
  const { data: membersData } = await supabase
    .from("tournament_entry_members")
    .select("*")
    .in("entry_id", entryIds);

  const members = (membersData ?? []) as TournamentEntryMember[];
  const userIds = Array.from(new Set(members.map((m) => m.user_id)));
  const { data: profilesData } = userIds.length
    ? await supabase.from("profiles").select("*").in("id", userIds)
    : { data: [] as Profile[] };

  const profilesById = new Map<string, Profile>();
  for (const profile of (profilesData ?? []) as Profile[]) {
    profilesById.set(profile.id, profile);
  }

  return registrations.map((registration) => ({
    ...registration,
    members: members
      .filter((m) => m.entry_id === registration.id)
      .map((m) => ({ ...m, profile: profilesById.get(m.user_id) ?? null })),
  }));
}

export interface MyRegistration {
  registration: TournamentRegistration;
  tournament: Tournament | null;
}

export async function getMyRegistrations(userId: string): Promise<MyRegistration[]> {
  const supabase = await createServerSupabaseClient();
  const { data: registrationsData, error } = await supabase
    .from("tournament_registrations")
    .select("*")
    .eq("user_id", userId)
    .order("registered_at", { ascending: false });

  if (error || !registrationsData) return [];
  const registrations = registrationsData as TournamentRegistration[];
  const tournamentIds = Array.from(new Set(registrations.map((r) => r.tournament_id)));

  const { data: tournamentsData } = tournamentIds.length
    ? await supabase.from("tournaments").select("*").in("id", tournamentIds)
    : { data: [] as Tournament[] };

  const tournamentsById = new Map<string, Tournament>();
  for (const tournament of (tournamentsData ?? []) as Tournament[]) {
    tournamentsById.set(tournament.id, tournament);
  }

  return registrations.map((registration) => ({
    registration,
    tournament: tournamentsById.get(registration.tournament_id) ?? null,
  }));
}

export async function getMyRegistrationForTournament(
  tournamentId: string,
  userId: string
): Promise<TournamentRegistration | null> {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("tournament_registrations")
    .select("*")
    .eq("tournament_id", tournamentId)
    .eq("user_id", userId)
    .maybeSingle();
  return data ?? null;
}

export interface TeamWithMembers extends Team {
  members: Array<TeamMember & { profile: Profile | null }>;
  invitations: TeamInvitation[];
  isCaptain: boolean;
}

export async function getMyTeams(userId: string): Promise<Team[]> {
  const supabase = await createServerSupabaseClient();
  const { data: memberships } = await supabase
    .from("team_members")
    .select("team_id")
    .eq("user_id", userId);

  const teamIds = (memberships ?? []).map((row) => row.team_id);
  if (teamIds.length === 0) return [];

  const { data, error } = await supabase
    .from("teams")
    .select("*")
    .in("id", teamIds)
    .is("deleted_at", null)
    .order("created_at", { ascending: false });

  if (error) return [];
  return data ?? [];
}

export async function getCaptainedTeams(userId: string): Promise<Team[]> {
  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase
    .from("teams")
    .select("*")
    .or(`owner_id.eq.${userId},captain_id.eq.${userId}`)
    .is("deleted_at", null)
    .order("created_at", { ascending: false });

  if (error) return [];
  return data ?? [];
}

export async function getTeamMemberCounts(
  teamIds: string[]
): Promise<Record<string, number>> {
  if (teamIds.length === 0) return {};
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("team_members")
    .select("team_id")
    .in("team_id", teamIds);

  const counts: Record<string, number> = {};
  for (const teamId of teamIds) counts[teamId] = 0;
  for (const row of data ?? []) {
    counts[row.team_id] = (counts[row.team_id] ?? 0) + 1;
  }
  return counts;
}

export async function getTeamDetail(
  teamId: string,
  userId: string
): Promise<TeamWithMembers | null> {
  const supabase = await createServerSupabaseClient();
  const { data: team, error } = await supabase
    .from("teams")
    .select("*")
    .eq("id", teamId)
    .is("deleted_at", null)
    .maybeSingle();

  if (error || !team) return null;

  const { data: memberRows } = await supabase
    .from("team_members")
    .select("*")
    .eq("team_id", teamId)
    .order("joined_at", { ascending: true });

  const members = (memberRows ?? []) as TeamMember[];
  const userIds = members.map((member) => member.user_id);
  const { data: profilesData } = userIds.length
    ? await supabase.from("profiles").select("*").in("id", userIds)
    : { data: [] as Profile[] };

  const profilesById = new Map<string, Profile>();
  for (const profile of (profilesData ?? []) as Profile[]) {
    profilesById.set(profile.id, profile);
  }

  const { data: invitationRows } = await supabase
    .from("team_invitations")
    .select("*")
    .eq("team_id", teamId)
    .eq("status", "pending")
    .order("created_at", { ascending: false });

  return {
    ...team,
    isCaptain: team.captain_id === userId || team.owner_id === userId,
    members: members.map((member) => ({
      ...member,
      profile: profilesById.get(member.user_id) ?? null,
    })),
    invitations: (invitationRows ?? []) as TeamInvitation[],
  };
}
