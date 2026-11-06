import Link from "next/link";
import { requireUser } from "@/lib/auth/require-user";
import { getUserPermissions } from "@/lib/auth/permissions";
import { getMyRegistrations, getMyTeams, getOrganizerTournaments } from "@/lib/data/tournaments";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const { user } = await requireUser("/dashboard");
  const [registrations, teams, organized, permissions] = await Promise.all([
    getMyRegistrations(user.id),
    getMyTeams(user.id),
    getOrganizerTournaments(user.id),
    getUserPermissions(user.id),
  ]);

  const activeEntries = registrations.filter(
    (item) => item.registration.status === "confirmed" || item.registration.status === "waitlisted"
  ).length;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-600">
          Signed in as {user.email}. {permissions.platformRole === "organizer"
            ? "Your account also organizes tournaments."
            : "Any account can host a tournament."}
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Active entries</CardDescription>
            <CardTitle className="text-3xl">{activeEntries}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Teams</CardDescription>
            <CardTitle className="text-3xl">{teams.length}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Tournaments hosted</CardDescription>
            <CardTitle className="text-3xl">{organized.length}</CardTitle>
          </CardHeader>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Find a tournament</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 text-sm text-gray-600">
            <p>Browse public tournaments and register solo or with your squad.</p>
            <Button asChild>
              <Link href="/tournaments">Browse tournaments</Link>
            </Button>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Build a squad</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 text-sm text-gray-600">
            <p>
              Create a team, invite players by email and complete the roster before
              registering for a squad tournament.
            </p>
            <Button asChild variant="outline">
              <Link href="/my-teams">Manage teams</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
