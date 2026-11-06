import { requireUser } from "@/lib/auth/require-user";
import { createTournamentAction } from "@/lib/actions/tournaments";
import { TournamentForm } from "@/components/tournament/tournament-form";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export const dynamic = "force-dynamic";

export default async function CreateTournamentPage() {
  await requireUser("/organizer/tournaments/create");

  return (
    <div className="mx-auto max-w-3xl">
      <Card>
        <CardHeader>
          <CardTitle>Create tournament</CardTitle>
          <CardDescription>
            Tournaments start as a draft. Publish when the configuration is final, then open
            registration. All dates are interpreted as UTC.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <TournamentForm action={createTournamentAction} submitLabel="Create draft" />
        </CardContent>
      </Card>
    </div>
  );
}
