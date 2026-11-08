import Link from "next/link";
import { notFound } from "next/navigation";
import { requireUser } from "@/lib/auth/require-user";
import { getOrganizerTournamentIds, getTournamentById, getTournamentRegistrations } from "@/lib/data/tournaments";
import { promoteWaitlistAction, setTournamentStatusAction } from "@/lib/actions/tournaments";
import { ActionForm } from "@/components/forms/action-form";
import { StatusBadge, formatDate, formatFormat } from "@/components/tournament/status-badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import type { TournamentStatus } from "@/types/supabase";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ status?: string; updated?: string }>;
}

const TRANSITIONS: Record<TournamentStatus, Array<{ to: TournamentStatus; label: string }>> = {
  draft: [{ to: "published", label: "Publish" }],
  published: [{ to: "registration_open", label: "Open registration" }],
  registration_open: [{ to: "registration_closed", label: "Close registration" }],
  registration_closed: [
    { to: "registration_open", label: "Reopen registration" },
    { to: "in_progress", label: "Mark in progress" },
  ],
  in_progress: [],
  completed: [],
  cancelled: [],
};

const REGISTRATION_STATUS_LABELS: Record<string, string> = {
  pending: "Pending",
  confirmed: "Confirmed",
  waitlisted: "Waitlisted",
  rejected: "Rejected",
  cancelled: "Withdrawn",
};

export default async function ManageTournamentPage({ params, searchParams }: PageProps) {
  const { id } = await params;
  const query = await searchParams;
  const { user } = await requireUser(`/organizer/tournaments/${id}`);

  const tournament = await getTournamentById(id);
  if (!tournament) notFound();

  const organizerIds = await getOrganizerTournamentIds(user.id);
  if (!organizerIds.includes(id)) notFound();

  const registrations = await getTournamentRegistrations(id);
  const confirmed = registrations.filter((entry) => entry.status === "confirmed");
  const waitlisted = registrations
    .filter((entry) => entry.status === "waitlisted")
    .sort((a, b) => (a.waitlist_seq ?? 0) - (b.waitlist_seq ?? 0));
  const withdrawn = registrations.filter((entry) => entry.status === "cancelled");

  const transitions = TRANSITIONS[tournament.status];
  const canCancel = ["draft", "published", "registration_open", "registration_closed"].includes(
    tournament.status
  );

  return (
    <div className="space-y-8">
      {query.status && (
        <div role="status" className="rounded-md bg-green-50 p-4 text-sm text-green-800">
          Tournament status updated to {query.status.replaceAll("_", " ")}.
        </div>
      )}
      {query.updated && (
        <div role="status" className="rounded-md bg-green-50 p-4 text-sm text-green-800">
          Tournament details saved.
        </div>
      )}

      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-start">
        <div>
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-3xl font-bold text-gray-900">{tournament.title}</h1>
            <StatusBadge status={tournament.status} />
          </div>
          <p className="mt-2 text-sm text-gray-600">
            {formatFormat(tournament.format, tournament.team_size)} ·{" "}
            {tournament.mode.toUpperCase()} · Capacity {tournament.max_teams} entries · Waitlist{" "}
            {tournament.waitlist_enabled ? "enabled" : "disabled"}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button asChild variant="outline" size="sm">
            <Link href={`/organizer/tournaments/${id}/edit`}>Edit details</Link>
          </Button>
          <Button asChild variant="ghost" size="sm">
            <Link href={`/tournaments/${id}`}>Public view</Link>
          </Button>
          <Button asChild variant="ghost" size="sm">
            <Link href={`/organizer/tournaments/${id}/announcements`}>Announcements</Link>
          </Button>
          <Button asChild variant="ghost" size="sm">
            <Link href="/organizer/dashboard">All tournaments</Link>
          </Button>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Confirmed</CardDescription>
            <CardTitle className="text-3xl">
              {confirmed.length}/{tournament.max_teams}
            </CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Waitlisted</CardDescription>
            <CardTitle className="text-3xl">{waitlisted.length}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Withdrawn</CardDescription>
            <CardTitle className="text-3xl">{withdrawn.length}</CardTitle>
          </CardHeader>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Lifecycle</CardTitle>
          <CardDescription>
            Transitions are validated server-side. Registration only works while registration is
            open and inside the configured window.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <dl className="grid gap-3 text-sm text-gray-700 sm:grid-cols-2">
            <div>
              <dt className="font-medium">Registration opens</dt>
              <dd>{formatDate(tournament.registration_starts_at)}</dd>
            </div>
            <div>
              <dt className="font-medium">Registration closes</dt>
              <dd>{formatDate(tournament.registration_ends_at)}</dd>
            </div>
            <div>
              <dt className="font-medium">Tournament starts</dt>
              <dd>{formatDate(tournament.tournament_starts_at)}</dd>
            </div>
            <div>
              <dt className="font-medium">Withdrawal deadline</dt>
              <dd>{formatDate(tournament.withdrawal_deadline ?? tournament.registration_ends_at)}</dd>
            </div>
          </dl>

          <div className="flex flex-wrap gap-2">
            {transitions.map((transition) => (
              <ActionForm
                key={transition.to}
                action={setTournamentStatusAction}
                submitLabel={transition.label}
                pendingLabel="Updating…"
                variant="outline"
                size="sm"
                className="inline-block"
              >
                <input type="hidden" name="tournamentId" value={id} />
                <input type="hidden" name="status" value={transition.to} />
              </ActionForm>
            ))}

            {tournament.status === "registration_open" && waitlisted.length > 0 && (
              <ActionForm
                action={promoteWaitlistAction}
                submitLabel="Promote next waitlisted"
                pendingLabel="Promoting…"
                variant="secondary"
                size="sm"
                className="inline-block"
                confirmMessage="Promote the next waitlisted entry even if capacity is not full?"
              >
                <input type="hidden" name="tournamentId" value={id} />
              </ActionForm>
            )}
          </div>

          {canCancel && (
            <div className="rounded-md border border-red-200 bg-red-50 p-4">
              <p className="text-sm font-medium text-red-800">Cancel tournament</p>
              <p className="mt-1 text-xs text-red-700">
                All active entries become cancelled and players are notified. This cannot be undone.
              </p>
              <ActionForm
                action={setTournamentStatusAction}
                submitLabel="Cancel tournament"
                pendingLabel="Cancelling…"
                variant="destructive"
                size="sm"
                className="mt-3 space-y-2"
                confirmMessage="Cancel this tournament? All active entries will be cancelled."
              >
                <input type="hidden" name="tournamentId" value={id} />
                <input type="hidden" name="status" value="cancelled" />
                <input
                  type="text"
                  name="reason"
                  placeholder="Reason shown to players (optional)"
                  maxLength={200}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
                />
              </ActionForm>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Confirmed entries</CardTitle>
          <CardDescription>Roster snapshots are stored at registration time.</CardDescription>
        </CardHeader>
        <CardContent>
          {confirmed.length === 0 ? (
            <p className="text-sm text-gray-600">No confirmed entries yet.</p>
          ) : (
            <div className="space-y-3">
              {confirmed.map((entry) => (
                <div key={entry.id} className="rounded-md border p-3 text-sm">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <p className="font-medium text-gray-900">
                      {entry.team_name ?? entry.members[0]?.profile?.display_name ?? "Entry"}
                    </p>
                    <span className="text-xs text-gray-500">
                      {entry.entry_type ?? "solo"} · registered {formatDate(entry.registered_at)}
                    </span>
                  </div>
                  <ul className="mt-2 space-y-1 text-xs text-gray-600">
                    {entry.members.map((member) => (
                      <li key={member.user_id}>
                        {member.profile?.display_name ?? "Player"}
                        {member.role === "captain" ? " (captain)" : ""}
                        {member.profile?.in_game_uid ? ` · UID ${member.profile.in_game_uid}` : ""}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Waitlist</CardTitle>
          <CardDescription>Promotion is FIFO and happens automatically on withdrawal.</CardDescription>
        </CardHeader>
        <CardContent>
          {waitlisted.length === 0 ? (
            <p className="text-sm text-gray-600">The waitlist is empty.</p>
          ) : (
            <ol className="space-y-2 text-sm">
              {waitlisted.map((entry, index) => (
                <li key={entry.id} className="flex flex-wrap justify-between gap-2 rounded-md border p-3">
                  <span className="font-medium text-gray-900">
                    {index + 1}. {entry.team_name ?? entry.members[0]?.profile?.display_name ?? "Entry"}
                  </span>
                  <span className="text-xs text-gray-500">
                    Waitlisted {formatDate(entry.waitlisted_at)}
                  </span>
                </li>
              ))}
            </ol>
          )}
        </CardContent>
      </Card>

      {withdrawn.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Withdrawn / cancelled</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="space-y-2 text-sm">
              {withdrawn.map((entry) => (
                <li key={entry.id} className="flex flex-wrap justify-between gap-2 rounded-md border p-3">
                  <span className="text-gray-900">
                    {entry.team_name ?? entry.members[0]?.profile?.display_name ?? "Entry"}
                  </span>
                  <span className="text-xs text-gray-500">
                    {REGISTRATION_STATUS_LABELS[entry.status] ?? entry.status}
                    {entry.withdrawn_at ? ` · ${formatDate(entry.withdrawn_at)}` : ""}
                  </span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
