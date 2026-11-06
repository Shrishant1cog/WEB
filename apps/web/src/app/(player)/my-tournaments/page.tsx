import Link from "next/link";
import { requireUser } from "@/lib/auth/require-user";
import { getMyRegistrations } from "@/lib/data/tournaments";
import { withdrawRegistrationAction } from "@/lib/actions/tournaments";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { StatusBadge, formatDate } from "@/components/tournament/status-badge";

export const dynamic = "force-dynamic";

const REGISTRATION_LABELS: Record<string, string> = {
  pending: "Pending",
  confirmed: "Confirmed",
  waitlisted: "Waitlisted",
  rejected: "Rejected",
  cancelled: "Withdrawn",
};

export default async function MyTournamentsPage() {
  const { user } = await requireUser("/my-tournaments");
  const registrations = await getMyRegistrations(user.id);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">My entries</h1>
        <p className="mt-1 text-sm text-gray-600">
          Tournament registrations linked to your account.
        </p>
      </div>

      {registrations.length === 0 ? (
        <Card>
          <CardContent className="p-10 text-center text-sm text-gray-600">
            You have not registered for a tournament yet.{" "}
            <Link href="/tournaments" className="font-medium text-indigo-600 hover:underline">
              Browse tournaments
            </Link>
            .
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {registrations.map(({ registration, tournament }) => {
            const deadline = tournament?.withdrawal_deadline ?? tournament?.registration_ends_at;
            const canWithdraw =
              Boolean(tournament) &&
              (registration.status === "confirmed" || registration.status === "waitlisted") &&
              tournament?.status === "registration_open" &&
              Boolean(deadline) &&
              Date.parse(deadline as string) >= Date.now();

            return (
              <Card key={registration.id}>
                <CardHeader className="flex flex-row items-start justify-between gap-3 space-y-0">
                  <div>
                    <CardTitle className="text-lg">
                      {tournament ? (
                        <Link
                          href={`/tournaments/${tournament.id}`}
                          className="hover:text-indigo-700"
                        >
                          {tournament.title}
                        </Link>
                      ) : (
                        "Tournament unavailable"
                      )}
                    </CardTitle>
                    <p className="mt-1 text-sm text-gray-600">
                      Entry type: {registration.entry_type ?? "solo"}
                      {registration.team_name ? ` · ${registration.team_name}` : ""}
                    </p>
                  </div>
                  {tournament && <StatusBadge status={tournament.status} />}
                </CardHeader>
                <CardContent className="space-y-3 text-sm text-gray-600">
                  <p>
                    Registration status:{" "}
                    <span className="font-medium text-gray-900">
                      {REGISTRATION_LABELS[registration.status] ?? registration.status}
                    </span>
                  </p>
                  {registration.status === "waitlisted" && (
                    <p className="text-amber-700">
                      You will be confirmed automatically when a spot opens.
                    </p>
                  )}
                  {tournament && (
                    <p>
                      Tournament starts {formatDate(tournament.tournament_starts_at)} ·{" "}
                      Withdrawal deadline {formatDate(deadline)}
                    </p>
                  )}
                  {canWithdraw ? (
                    <ActionForm
                      action={withdrawRegistrationAction}
                      submitLabel="Withdraw"
                      pendingLabel="Withdrawing…"
                      variant="outline"
                      size="sm"
                      confirmMessage="Withdraw from this tournament?"
                    >
                      <input type="hidden" name="entryId" value={registration.id} />
                      <input type="hidden" name="tournamentId" value={registration.tournament_id} />
                    </ActionForm>
                  ) : (
                    tournament && (
                      <p className="text-xs text-gray-500">
                        Withdrawal is not available (registration closed or deadline passed).
                      </p>
                    )
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      <Button asChild variant="outline">
        <Link href="/tournaments">Find more tournaments</Link>
      </Button>
    </div>
  );
}
