import Link from "next/link";
import { getPublicTournaments } from "@/lib/data/tournaments";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FormInput } from "@/components/ui/input";
import { SkeletonCard, SkeletonList } from "@/components/ui/skeleton";
import { EmptyState, EmptyStates, ErrorState } from "@/components/ui/empty-error";
import { StatusBadge, formatDate, formatFormat } from "@/components/tournament/status-badge";
import { TournamentCard, TournamentCardList } from "@/components/tournament/tournament-card";

export const dynamic = "force-dynamic";

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
];

export default async function TournamentsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; status?: string; mode?: string }>;
}) {
  const params = await searchParams;
  const tournaments = await getPublicTournaments({
    query: params.q,
    status: params.status,
    mode: params.mode,
  });

  return (
    <div className="mx-auto max-w-6xl px-4 py-10">
      {/* Header */}
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end mb-8">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Tournaments</h1>
          <p className="mt-1 text-body-md text-muted-foreground">
            Public tournaments. Times are shown in UTC.
          </p>
        </div>
        <Button asChild variant="outline" size="sm">
          <Link href="/organizer/tournaments/create">Host a tournament</Link>
        </Button>
      </div>

      {/* Search & Filters */}
      <form method="get" className="mb-8 space-y-4 rounded-xl border bg-card p-6">
        {/* Search field */}
        <div>
          <label htmlFor="q" className="mb-1.5 block text-label-md font-medium text-foreground">
            Search tournaments
          </label>
          <FormInput
            id="q"
            name="q"
            placeholder="Search by name..."
            defaultValue={params.q ?? ""}
            leadingIcon={
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            }
          />
        </div>

        {/* Filters */}
        <div className="grid gap-3 sm:grid-cols-2">
          {/* Mode filter */}
          <div>
            <label htmlFor="mode" className="mb-1.5 block text-label-md font-medium text-foreground">
              Mode
            </label>
            <select
              id="mode"
              name="mode"
              defaultValue={params.mode ?? "all"}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-body-md transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {MODE_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          {/* Status filter */}
          <div>
            <label htmlFor="status" className="mb-1.5 block text-label-md font-medium text-foreground">
              Status
            </label>
            <select
              id="status"
              name="status"
              defaultValue={params.status ?? "all"}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-body-md transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {STATUS_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Filter actions */}
        <div className="pt-2 flex items-center justify-end gap-2">
          <Button type="button" variant="outline" onClick={() => window.location.href = '/tournaments'}>
            Reset
          </Button>
          <Button type="submit" variant="default">
            Filter
          </Button>
        </div>
      </form>

      {/* Tournament List */}
      <div className="space-y-6">
        {tournaments.length === 0 ? (
          EmptyStates.noTournaments
        ) : (
          <TournamentCardList
            tournaments={tournaments.map((t) => ({
              ...t,
              is_full: t.confirmed_entries >= t.max_teams,
              status: t.status as any,
            }))}
            onCardClick={(t) => window.location.href = `/tournaments/${t.id}`}
          />
        )}
      </div>
    </div>
  );
}