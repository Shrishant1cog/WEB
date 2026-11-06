import { notFound } from "next/navigation";
import { requireUser } from "@/lib/auth/require-user";
import { getTournamentById } from "@/lib/data/tournaments";
import { updateTournamentAction } from "@/lib/actions/tournaments";
import { TournamentForm } from "@/components/tournament/tournament-form";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function EditTournamentPage({ params }: PageProps) {
  const { id } = await params;
  const { user } = await requireUser(`/organizer/tournaments/${id}/edit`);
  const tournament = await getTournamentById(id);

  if (!tournament) notFound();

  // Authorization is enforced by the update RPC; this early check only avoids
  // showing an edit form the user cannot submit.
  if (tournament.organizer_id !== user.id) {
    const { getOrganizerTournamentIds } = await import("@/lib/data/tournaments");
    const ids = await getOrganizerTournamentIds(user.id);
    if (!ids.includes(id)) notFound();
  }

  const editable = ["draft", "published", "registration_open"].includes(tournament.status);

  return (
    <div className="mx-auto max-w-3xl">
      <Card>
        <CardHeader>
          <CardTitle>Edit tournament</CardTitle>
          <CardDescription>
            {editable
              ? "Changes are audited. All dates are interpreted as UTC."
              : "This tournament can no longer be edited because registration has closed."}
          </CardDescription>
        </CardHeader>
        <CardContent>
          {editable ? (
            <TournamentForm
              action={updateTournamentAction}
              tournament={tournament}
              submitLabel="Save changes"
            />
          ) : (
            <p className="text-sm text-gray-600">
              Return to the management page to review registrations or change the status.
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
