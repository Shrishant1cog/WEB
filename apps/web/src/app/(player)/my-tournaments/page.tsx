import Link from "next/link";
import { requireUser } from "@/lib/auth/require-user";
import { getMyRegistrations } from "@/lib/data/tournaments";
import { withdrawRegistrationAction } from "@/lib/actions/tournaments";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { StatusBadge, formatDate } from "@/components/tournament/status-badge";
import { EmptyStates } from "@/components/ui/empty-error";

export const dynamic = "force-dynamic";

const REGISTRATION_LABELS: Record<string, string> = {
  pending: "Pending",
  confirmed: "Confirmed",
  waitlisted: "Waitlisted",
  rejected: "Rejected",
  cancelled: "Withdrawn",
};

const now = Date.now();

export default async function MyTournamentsPage() {
  const { user } = await requireUser("/my-tournaments");
  const registrations = await getMyRegistrations(user.id);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-headline-lg font-bold text-foreground">My entries</h1>
        <p className="mt-1 text-body-md text-muted-foreground">
          Tournament registrations linked to your account.
        </p>
      </div>

      {registrations.length === 0 ? (
        EmptyStates.noTournaments
      ) : (
        <>
          <div className="space-y-4">
            {registrations.map(({ registration, tournament }) => {
              const deadline = tournament?.withdrawal_deadline ?? tournament?.registration_ends_at;
              const canWithdraw =
                Boolean(tournament) &&
                (registration.status === "confirmed" || registration.status === "waitlisted") &&
                tournament?.status === "registration_open" &&
                Boolean(deadline) &&
                Date.parse(deadline as string) >= now;

              return (
                <Card key={registration.id} className="border-border/50 hover:border-primary/30 transition-colors">
                  <CardHeader className="flex flex-row items-start justify-between gap-3 space-y-0 pb-3">
                    <div className="flex-1 min-w-0">
                      <CardTitle className="text-title-md">
                        {tournament ? (
                          <Link
                            href={`/tournaments/${tournament.id}`}
                            className="hover:text-primary transition-colors"
                          >
                            {tournament.title}
                          </Link>
                        ) : (
                          "Tournament unavailable"
                        )}
                      </CardTitle>
                      <p className="mt-1 text-body-sm text-muted-foreground">
                        Entry type: {registration.entry_type ?? "solo"}
                        {registration.team_name ? ` · ${registration.team_name}` : ""}
                      </p>
                    </div>
                    {tournament && <StatusBadge status={tournament.status as any} />}
                  </CardHeader>
                  <CardContent className="space-y-3 text-body-sm text-muted-foreground">
                    <p>
                      Registration status:{" "}
                      <span className="font-medium text-foreground">
                        {REGISTRATION_LABELS[registration.status] ?? registration.status}
                      </span>
                    </p>
                    {registration.status === "waitlisted" && (
                      <p className="text-warning">
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
                    ) : tournament && (
                      <p className="text-xs text-muted-foreground">
                        Withdrawal is not available (registration closed or deadline passed).
                      </p>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>

          <div className="pt-4">
            <Button asChild variant="outline" className="w-full sm:w-auto">
              <Link href="/tournaments">Find more tournaments</Link>
            </Button>
          </div>
        </>
      )}
    </div>
  );
}