import type { TournamentStatus } from "@/types/supabase";

const LABELS: Record<TournamentStatus, string> = {
  draft: "Draft",
  published: "Published",
  registration_open: "Registration open",
  registration_closed: "Registration closed",
  in_progress: "In progress",
  completed: "Completed",
  cancelled: "Cancelled",
};

const STYLES: Record<TournamentStatus, string> = {
  draft: "tournament-status-draft",
  published: "tournament-status-published",
  registration_open: "tournament-status-registration_open",
  registration_closed: "tournament-status-registration_closed",
  in_progress: "tournament-status-in_progress",
  completed: "tournament-status-completed",
  cancelled: "tournament-status-cancelled",
};

interface StatusBadgeProps {
  status: TournamentStatus | string;
  compact?: boolean;
  className?: string;
}

export function StatusBadge({ status, compact = false, className }: StatusBadgeProps) {
  const statusKey = status as TournamentStatus;
  return (
    <span
      className={`
        inline-flex items-center rounded-full px-2.5 py-0.5 font-medium
        border transition-colors
        ${STYLES[statusKey]}
        ${compact ? 'text-xs px-2 py-0.5' : 'text-sm px-3 py-1'}
        ${className}
      `}
    >
      {LABELS[statusKey] ?? status}
    </span>
  );
}

export function formatDate(value: string | null | undefined): string {
  if (!value) return "—";
  return new Date(value).toLocaleString("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
    timeZone: "UTC",
  }) + " UTC";
}

export function formatFormat(format: string, teamSize: number): string {
  if (format === "solo") return "Solo";
  if (format === "duo") return "Duo";
  if (format === "squad") return `Squad (${teamSize})`;
  return "Custom";
}

export function formatDateOnly(value: string | null | undefined): string {
  if (!value) return "—";
  return new Date(value).toLocaleDateString("en-IN", {
    dateStyle: "medium",
    timeZone: "UTC",
  }) + " UTC";
}