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
  draft: "bg-gray-100 text-gray-700",
  published: "bg-indigo-100 text-indigo-800",
  registration_open: "bg-green-100 text-green-800",
  registration_closed: "bg-amber-100 text-amber-800",
  in_progress: "bg-blue-100 text-blue-800",
  completed: "bg-gray-200 text-gray-800",
  cancelled: "bg-red-100 text-red-800",
};

export function StatusBadge({ status }: { status: TournamentStatus }) {
  return (
    <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-medium ${STYLES[status]}`}>
      {LABELS[status]}
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
