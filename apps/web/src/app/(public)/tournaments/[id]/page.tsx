import Link from "next/link";
import { notFound } from "next/navigation";
import { getServerUser } from "@/lib/supabase/client";
import {
  getCaptainedTeams,
  getMyRegistrationForTournament,
  getPublicTournament,
  getTeamMemberCounts,
  isOrganizerOf,
} from "@/lib/data/tournaments";
import { registerTournamentAction, withdrawRegistrationAction } from "@/lib/actions/tournaments";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ActionForm } from "@/components/forms/action-form";
import { TournamentRegisterForm } from "@/components/tournament/register-form";
import { StatusBadge, formatDate, formatFormat } from "@/components/tournament/status-badge";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ registered?: string; position?: string }>;
}

const STATUS_LABELS: Record<string, string> = {
  pending: "Pending",
  confirmed: "Confirmed",
  waitlisted: "Waitlisted",
  rejected: "Rejected",
  cancelled: "Withdrawn",
};

const now = Date.now();

export default async function TournamentDetailPage({ params, searchParams }: PageProps) {
  const { id } = await params;
  const query = await searchParams;
  const tournament = await getPublicTournament(id);
  if (!tournament) notFound();

  const user = await getServerUser();
  const registration = user ? await getMyRegistrationForTournament(id, user.id) : null;
  const isOrganizer = user ? await isOrganizerOf(id, user.id) : false;

  const requiresTeam = tournament.format !== "solo";
  const captainTeams = user && requiresTeam ? await getCaptainedTeams(user.id) : [];
  const memberCounts = await getTeamMemberCounts(captainTeams.map((team) => team.id));
  const teamOptions = captainTeams.map((team) => ({
    id: team.id,
    name: team.name,
    memberCount: memberCounts[team.id] ?? 0,
  }));

  const withdrawalDeadline = tournament.withdrawal_deadline ?? tournament.registration_ends_at;
  const canWithdraw =
    registration !== null &&
    (registration.status === "confirmed" || registration.status === "waitlisted") &&
    tournament.status === "registration_open" &&
    Date.parse(withdrawalDeadline) >= now;

  const hasActiveEntry =
    registration !== null && registration.status !== "cancelled" && registration.status !== "rejected";

  return (
    <div className="mx-auto max-w-5xl px-4 py-10">
      {/* Registration confirmation banner */}
      {query.registered && (
        <div
          role="status"
          className="mb-6 rounded-lg bg-success/10 p-4 text-sm text-success"
        >
          {query.registered === "waitlisted"
            ? `Tournament is full — you are on the waitlist${
                query.position ? ` at position ${query.position}` : ""
              }. You will be confirmed automatically if a spot opens.`
            : "Your registration is confirmed."}
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-start mb-8">
        <div>
          <div className="flex flex-wrap items-center gap-3 mb-2">
            <h1 className="text-headline-lg font-bold text-foreground">{tournament.title}</h1>
            <StatusBadge status={tournament.status as any} />
          </div>
          <p className="text-body-md text-muted-foreground">
            Hosted by {tournament.organizer_name} ·{" "}
            {formatFormat(tournament.format, tournament.team_size)} ·{" "}
            {tournament.mode.toUpperCase()}
          </p>
        </div>
        {isOrganizer && (
          <Button asChild variant="outline">
            <Link href={`/organizer/tournaments/${tournament.id}`}>Manage tournament</Link>
          </Button>
        )}
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="space-y-6 lg:col-span-2">
          {/* Schedule Card */}
          <Card>
            <CardHeader>
              <CardTitle>Schedule</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-3 text-body-sm text-muted-foreground sm:grid-cols-2">
              <p>
                <span className="font-medium text-foreground">Registration opens:</span>{" "}
                {formatDate(tournament.registration_starts_at)}
              </p>
              <p>
                <span className="font-medium text-foreground">Registration closes:</span>{" "}
                {formatDate(tournament.registration_ends_at)}
              </p>
              <p>
                <span className="font-medium text-foreground">Tournament starts:</span>{" "}
                {formatDate(tournament.tournament_starts_at)}
              </p>
              <p>
                <span className="font-medium text-foreground">Tournament ends:</span>{" "}
                {formatDate(tournament.tournament_ends_at)}
              </p>
              <p>
                <span className="font-medium text-foreground">Withdrawal deadline:</span>{" "}
                {formatDate(tournament.withdrawal_deadline ?? tournament.registration_ends_at)}
              </p>
              <p>
                <span className="font-medium text-foreground">Map:</span> {tournament.map ?? "TBA"}
              </p>
            </CardContent>
          </Card>

          {/* Rules & Eligibility Card */}
          <Card>
            <CardHeader>
              <CardTitle>Rules & eligibility</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-body-sm text-muted-foreground">
              {tournament.description && <p>{tournament.description}</p>}
              <p>
                <span className="font-medium text-foreground">Roster size:</span> {tournament.team_size}{" "}
                {requiresTeam ? "players per team" : "player per entry"}
              </p>
              <p>
                <span className="font-medium text-foreground">Capacity:</span> {tournament.max_teams} entries
              </p>
              <p>
                <span className="font-medium text-foreground">Waitlist:</span>{" "}
                {tournament.waitlist_enabled
                  ? "Enabled — filled entries join a FIFO waitlist that promotes automatically."
                  : "Disabled — registration closes when capacity is reached."}
              </p>
              <p>
                <span className="font-medium text-foreground">In-game UID required:</span>{" "}
                {Boolean((tournament.eligibility as Record<string, unknown>)?.requires_ingame_id)
                  ? "Yes — every roster member must add their Free Fire UID to their profile."
                  : "No"}
              </p>
              {tournament.prize_pool && (
                <p>
                  <span className="font-medium text-foreground">Prize description:</span> {tournament.prize_pool}
                </p>
              )}
              {tournament.rules_text && (
                <div className="whitespace-pre-wrap rounded-lg border bg-muted p-4 text-body-sm text-muted-foreground">
                  {tournament.rules_text}
                </div>
              )}
              {tournament.rules_url && (
                <p>
                  <a
                    href={tournament.rules_url}
                    target="_blank"
                    rel="noreferrer noopener"
                    className="font-medium text-primary hover:underline"
                  >
                    External rules document
                  </a>
                </p>
              )}
              {tournament.contact_info && (
                <p>
                  <span className="font-medium text-foreground">Contact:</span> {tournament.contact_info}
                </p>
              )}
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          {/* Registration Card */}
          <Card>
            <CardHeader>
              <CardTitle>Registration</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 text-body-sm">
              <p className="text-muted-foreground">
                {tournament.confirmed_entries}/{tournament.max_teams} entries confirmed
                {tournament.waitlisted_entries > 0 && (
                  <span className="block text-warning">
                    {tournament.waitlisted_entries} on the waitlist
                  </span>
                )}
              </p>

              {!user ? (
                <Button asChild className="w-full">
                  <Link href={`/login?redirect=${encodeURIComponent(`/tournaments/${id}`)}`}>
                    Sign in to register
                  </Link>
                </Button>
              ) : hasActiveEntry ? (
                <div className="space-y-3">
                  <p className="font-medium text-foreground">
                    Your entry: {STATUS_LABELS[registration.status] ?? registration.status}
                  </p>
                  {registration.status === "waitlisted" && (
                    <p className="text-warning">
                      You will be confirmed automatically when a spot opens.
                    </p>
                  )}
                  {canWithdraw ? (
                    <ActionForm
                      action={withdrawRegistrationAction}
                      submitLabel="Withdraw"
                      pendingLabel="Withdrawing…"
                      variant="outline"
                      confirmMessage="Withdraw from this tournament?"
                    >
                      <input type="hidden" name="entryId" value={registration.id} />
                      <input type="hidden" name="tournamentId" value={id} />
                    </ActionForm>
                  ) : (
                    <p className="text-xs text-muted-foreground">
                      Withdrawals are closed for this tournament.
                    </p>
                  )}
                </div>
              ) : tournament.status !== "registration_open" ? (
                <p className="text-muted-foreground">Registration is not open.</p>
              ) : (
                <>
                  {registration?.status === "cancelled" && (
                    <p className="text-xs text-muted-foreground">
                      Your previous entry was withdrawn. You can register again while
                      registration is open.
                    </p>
                  )}
                  <TournamentRegisterForm
                    action={registerTournamentAction}
                    tournamentId={id}
                    entryType={requiresTeam ? "squad" : "solo"}
                    teams={teamOptions}
                    requiredRosterSize={tournament.team_size}
                  />
                </>
              )}
            </CardContent>
          </Card>

          {/* Fair Play Card */}
          <Card>
            <CardHeader>
              <CardTitle>Fair play</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2 text-xs text-muted-foreground">
              <p>One entry per player per tournament is enforced by the database.</p>
              <p>Capacity is transactional: simultaneous registrations cannot oversell.</p>
              <p>
                FFT is independent and not affiliated with Garena. Organizers are
                responsible for their own tournament rules and conduct.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}