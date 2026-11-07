import Link from "next/link";
import { requireUser } from "@/lib/auth/require-user";
import { getOrganizerTournaments } from "@/lib/data/tournaments";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { StatusBadge, formatDate, formatFormat } from "@/components/tournament/status-badge";
import { EmptyState, EmptyStates } from "@/components/ui/empty-error";

export const dynamic = "force-dynamic";

export default async function OrganizerDashboardPage() {
  const { user } = await requireUser("/organizer/dashboard");
  const tournaments = await getOrganizerTournaments(user.id);

  const openForRegistration = tournaments.filter(
    (tournament) => tournament.status === "registration_open"
  ).length;
  const drafts = tournaments.filter((tournament) => tournament.status === "draft").length;

  return (
    <div className="space-y-8">
      <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-end">
        <div>
          <h1 className="text-headline-lg font-bold text-foreground">Organizer dashboard</h1>
          <p className="mt-1 text-body-md text-muted-foreground">
            Create tournaments, publish them and manage registrations. All times are UTC.
          </p>
        </div>
        <Button asChild>
          <Link href="/organizer/tournaments/create">Create tournament</Link>
        </Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="border-primary/20">
          <CardHeader className="pb-2">
            <CardDescription>Tournaments</CardDescription>
            <CardTitle className="text-4xl font-bold text-primary">{tournaments.length}</CardTitle>
          </CardHeader>
        </Card>
        <Card className="border-emerald-500/20">
          <CardHeader className="pb-2">
            <CardDescription>Open for registration</CardDescription>
            <CardTitle className="text-4xl font-bold text-emerald-500">{openForRegistration}</CardTitle>
          </CardHeader>
        </Card>
        <Card className="border-slate-500/20">
          <CardHeader className="pb-2">
            <CardDescription>Drafts</CardDescription>
            <CardTitle className="text-4xl font-bold text-slate-500">{drafts}</CardTitle>
          </CardHeader>
        </Card>
      </div>

      {tournaments.length === 0 ? (
        EmptyStates.noTournaments
      ) : (
        <div className="space-y-4">
          {tournaments.map((tournament) => (
            <Card key={tournament.id} className="border-border/50 hover:border-primary/30 transition-colors">
              <CardHeader className="flex flex-row items-start justify-between gap-3 space-y-0 pb-3">
                <div className="flex-1 min-w-0">
                  <CardTitle className="text-title-md">
                    <Link
                      href={`/organizer/tournaments/${tournament.id}`}
                      className="hover:text-primary transition-colors"
                    >
                      {tournament.title}
                    </Link>
                  </CardTitle>
                  <p className="mt-1 text-body-sm text-muted-foreground">
                    {formatFormat(tournament.format, tournament.team_size)} ·{" "}
                    {tournament.mode.toUpperCase()} · Capacity {tournament.max_teams} entries
                  </p>
                </div>
                <StatusBadge status={tournament.status as any} />
              </CardHeader>
              <CardContent className="flex flex-col justify-between gap-3 text-body-sm text-muted-foreground sm:flex-row sm:items-center">
                <div className="space-y-1">
                  <p>
                    Registration: {formatDate(tournament.registration_starts_at)} →{" "}
                    {formatDate(tournament.registration_ends_at)}
                  </p>
                  <p>Starts: {formatDate(tournament.tournament_starts_at)}</p>
                </div>
                <div className="flex flex-wrap gap-2">
                  <Button asChild variant="outline" size="sm">
                    <Link href={`/organizer/tournaments/${tournament.id}`}>Manage</Link>
                  </Button>
                  <Button asChild variant="ghost" size="sm">
                    <Link href={`/tournaments/${tournament.id}`}>Public view</Link>
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}