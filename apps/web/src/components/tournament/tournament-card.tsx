"use client";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { StatusBadge, formatDate, formatFormat } from "@/components/tournament/status-badge";

interface TournamentCardProps {
  tournament: {
    id: string;
    title: string;
    status: string;
    format: string;
    team_size: number;
    mode: string;
    map: string | null;
    organizer_name: string;
    tournament_starts_at: string;
    confirmed_entries: number;
    max_teams: number;
    waitlisted_entries: number;
    prize_pool: string | null;
    is_full: boolean;
  };
  onClick?: () => void;
  compact?: boolean;
  showActions?: boolean;
}

export function TournamentCard({
  tournament,
  onClick,
  compact = false,
  showActions = true,
}: TournamentCardProps) {
  const isFull = tournament.is_full || tournament.confirmed_entries >= tournament.max_teams;

  return (
    <article
      className={cn(
        'rounded-xl border bg-card text-card-foreground shadow-sm transition-all duration-200',
        'hover:shadow-card-hover hover:border-primary/30',
        onClick && 'cursor-pointer',
        compact && 'p-4',
        !compact && 'p-6'
      )}
      onClick={onClick}
    >
      {/* Header: Title + Status */}
      <div className="flex items-start justify-between gap-3">
        <h3 className={cn(
          'font-semibold leading-tight truncate',
          compact ? 'text-title-md' : 'text-title-lg'
        )}>
          {tournament.title}
        </h3>
        <StatusBadge status={tournament.status} compact={compact} />
      </div>

      {!compact && (
        <>
          {/* Meta row: Format · Mode · Map · Organizer */}
          <div className="mt-2 text-body-sm text-muted-foreground">
            <span className="whitespace-nowrap">
              {formatFormat(tournament.format, tournament.team_size)} ·{" "}
              {tournament.mode.toUpperCase()} ·{" "}
              {tournament.map ?? 'Map TBA'} ·{" "}
              by {tournament.organizer_name}
            </span>
          </div>

          {/* Info row: Date + Capacity */}
          <div className="mt-3 flex flex-wrap items-center gap-4 text-body-sm text-muted-foreground">
            <span className="flex items-center gap-1.5">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              {formatDate(tournament.tournament_starts_at)}
            </span>
            <span className="flex items-center gap-1.5">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              {tournament.confirmed_entries}/{tournament.max_teams}
            </span>
          </div>

          {/* Status badges row */}
          <div className="mt-3 flex flex-wrap items-center gap-2">
            {isFull && (
              <span className="inline-flex items-center rounded-full border border-warning/20 bg-warning/10 px-2.5 py-1 text-xs font-medium text-warning">
                Full
              </span>
            )}
            {tournament.prize_pool && tournament.prize_pool.trim() !== '' && (
              <span className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/10 px-2.5 py-1 text-xs font-medium text-primary">
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
                </svg>
                <span className="truncate max-w-[150px]">{tournament.prize_pool}</span>
              </span>
            )}
          </div>

          {showActions && (
            <div className="mt-4 pt-4 border-t">
              <Button
                variant="outline"
                className="w-full"
                onClick={onClick}
              >
                View details
              </Button>
            </div>
          )}
        </>
      )}
    </article>
  );
}

interface TournamentCardListProps {
  tournaments: TournamentCardProps['tournament'][];
  onCardClick?: (tournament: TournamentCardProps['tournament']) => void;
  compact?: boolean;
  showActions?: boolean;
  className?: string;
  emptyState?: React.ReactNode;
}

export function TournamentCardList({
  tournaments,
  onCardClick,
  compact = false,
  showActions = true,
  className,
  emptyState,
}: TournamentCardListProps) {
  if (tournaments.length === 0) {
    return (
      <div className={cn('py-12', className)}>
        {emptyState || (
          <div className="text-center">
            <div className="mx-auto flex items-center justify-center w-20 h-20 rounded-2xl bg-primary/10 text-primary">
              <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
            <h3 className="mt-6 text-title-lg font-semibold text-foreground">No tournaments found</h3>
            <p className="mt-2 text-body-md text-muted-foreground">Try a different search or filter.</p>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className={cn('grid gap-4 md:grid-cols-2 lg:grid-cols-3', className)}>
      {tournaments.map((tournament) => (
        <TournamentCard
          key={tournament.id}
          tournament={tournament}
          onClick={() => onCardClick?.(tournament)}
          compact={compact}
          showActions={showActions}
        />
      ))}
    </div>
  );
}