import Link from "next/link";
import { getPublicTournaments } from "@/lib/data/tournaments";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { StatusBadge, formatDate, formatFormat } from "@/components/tournament/status-badge";

export const dynamic = "force-dynamic";

interface PageProps {
  searchParams: Promise<{ q?: string; status?: string; mode?: string }>;
}

const STATUS_OPTIONS = [
  { value: "all", label: "All statuses" },
  { value: "registration_open", label: "Open for registration" },
  { value: "published", label: "Published" },
  { value: "registration_closed", label: "Registration closed" },
  { value: "in_progress", label: "In progress" },
  { value: "completed", label: "Completed" },
];

const MODE_OPTIONS = [
  { value: "all", label: "All modes" },
  { value: "br", label: "Battle Royale" },
  { value: "cs", label: "Clash Squad" },
  { value: "tdm", label: "Team Deathmatch" },
  { value: "custom", label: "Custom" },
];

export default async function TournamentsPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const tournaments = await getPublicTournaments({
    query: params.q,
    status: params.status,
    mode: params.mode,
  });

  return (
    <div className="mx-auto max-w-6xl px-4 py-10">
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Tournaments</h1>
          <p className="mt-1 text-sm text-gray-600">
            Public tournaments. Times are shown in UTC.
          </p>
        </div>
        <Button asChild variant="outline">
          <Link href="/organizer/tournaments/create">Host a tournament</Link>
        </Button>
      </div>

      <form method="get" className="mt-6 grid gap-3 rounded-lg border bg-white p-4 sm:grid-cols-4">
        <div className="sm:col-span-2">
          <label htmlFor="q" className="text-xs font-medium text-gray-600">
            Search
          </label>
          <input
            id="q"
            name="q"
            defaultValue={params.q ?? ""}
            placeholder="Tournament title"
            className="mt-1 w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label htmlFor="status" className="text-xs font-medium text-gray-600">
            Status
          </label>
          <select
            id="status"
            name="status"
            defaultValue={params.status ?? "all"}
            className="mt-1 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm"
          >
            {STATUS_OPTIONS.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label htmlFor="mode" className="text-xs font-medium text-gray-600">
            Mode
          </label>
          <div className="mt-1 flex gap-2">
            <select
              id="mode"
              name="mode"
              defaultValue={params.mode ?? "all"}
              className="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm"
            >
              {MODE_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
            <Button type="submit" size="sm">
              Filter
            </Button>
          </div>
        </div>
      </form>

      {tournaments.length === 0 ? (
        <Card className="mt-8">
          <CardContent className="p-10 text-center text-sm text-gray-600">
            No tournaments match these filters yet.
          </CardContent>
        </Card>
      ) : (
        <div className="mt-8 grid gap-4 md:grid-cols-2">
          {tournaments.map((tournament) => (
            <Card key={tournament.id}>
              <CardHeader className="flex flex-row items-start justify-between gap-3 space-y-0">
                <div>
                  <CardTitle className="text-lg">
                    <Link href={`/tournaments/${tournament.id}`} className="hover:text-indigo-700">
                      {tournament.title}
                    </Link>
                  </CardTitle>
                  <p className="mt-1 text-sm text-gray-600">
                    {formatFormat(tournament.format, tournament.team_size)} ·{" "}
                    {tournament.mode.toUpperCase()} · {tournament.map ?? "Map TBA"}
                  </p>
                </div>
                <StatusBadge status={tournament.status} />
              </CardHeader>
              <CardContent className="space-y-2 text-sm text-gray-600">
                <p>
                  Starts {formatDate(tournament.tournament_starts_at)} · Hosted by{" "}
                  {tournament.organizer_name}
                </p>
                <p>
                  {tournament.confirmed_entries}/{tournament.max_teams} entries confirmed
                  {tournament.waitlisted_entries > 0
                    ? ` · ${tournament.waitlisted_entries} waitlisted`
                    : ""}
                </p>
                <Link
                  href={`/tournaments/${tournament.id}`}
                  className="inline-block font-medium text-indigo-600 hover:underline"
                >
                  View details
                </Link>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
