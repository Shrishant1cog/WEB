import { requireUser } from "@/lib/auth/require-user";
import { TeamForm } from "@/components/team/team-form";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export const dynamic = "force-dynamic";

export default async function CreateTeamPage() {
  await requireUser("/my-teams/create");

  return (
    <div className="mx-auto max-w-xl">
      <Card>
        <CardHeader>
          <CardTitle>Create a team</CardTitle>
          <CardDescription>
            You become the captain. Invite players from the team page afterwards.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <TeamForm />
        </CardContent>
      </Card>
    </div>
  );
}
