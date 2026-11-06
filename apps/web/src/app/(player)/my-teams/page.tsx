import Link from "next/link";
import { requireUser } from "@/lib/auth/require-user";
import { getMyTeams, getTeamMemberCounts } from "@/lib/data/tournaments";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export const dynamic = "force-dynamic";

export default async function MyTeamsPage() {
  const { user } = await requireUser("/my-teams");
  const teams = await getMyTeams(user.id);
  const counts = await getTeamMemberCounts(teams.map((team) => team.id));

  return (
    <div className="space-y-6">
      <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">My teams</h1>
          <p className="mt-1 text-sm text-gray-600">
            Squads you belong to. Only the captain can register a team.
          </p>
        </div>
        <Button asChild>
          <Link href="/my-teams/create">Create team</Link>
        </Button>
      </div>

      {teams.length === 0 ? (
        <Card>
          <CardContent className="p-10 text-center text-sm text-gray-600">
            You are not in a team yet. Create one to register for squad tournaments.
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {teams.map((team) => {
            const isCaptain = team.captain_id === user.id || team.owner_id === user.id;
            return (
              <Card key={team.id}>
                <CardHeader className="flex flex-row items-start justify-between gap-3 space-y-0">
                  <div>
                    <CardTitle className="text-lg">
                      <Link href={`/my-teams/${team.id}`} className="hover:text-indigo-700">
                        {team.name}
                      </Link>
                    </CardTitle>
                    <p className="mt-1 text-sm text-gray-600">
                      {team.tag ? `[${team.tag}] · ` : ""}
                      {counts[team.id] ?? 0}/{team.max_members} members
                    </p>
                  </div>
                  {isCaptain && (
                    <span className="rounded-full bg-indigo-100 px-2.5 py-0.5 text-xs font-medium text-indigo-800">
                      Captain
                    </span>
                  )}
                </CardHeader>
                <CardContent>
                  <Link
                    href={`/my-teams/${team.id}`}
                    className="text-sm font-medium text-indigo-600 hover:underline"
                  >
                    Open team
                  </Link>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
