import { createServerSupabaseClient } from "@/lib/supabase/client";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Plus, Calendar, Users, Trophy, ArrowRight } from "lucide-react";
import Link from "next/link";

export default async function OrganizerDashboardPage() {
  const supabase = createServerSupabaseClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  // Get tournaments organized by this user
  const { data: tournaments } = await supabase
    .from("tournaments")
    .select(`
      id,
      name,
      status,
      start_date,
      end_date,
      max_teams,
      registration_open,
      registration_close,
      tournament_organizers!inner(user_id, role)
    `)
    .eq("tournament_organizers.user_id", user.id)
    .order("created_at", { ascending: false });

  // Get stats
  const { count: totalTournaments } = await supabase
    .from("tournaments")
    .select("*", { count: "exact", head: true })
    .eq("tournament_organizers.user_id", user.id);

  const { count: activeTournaments } = await supabase
    .from("tournaments")
    .select("*", { count: "exact", head: true })
    .eq("tournament_organizers.user_id", user.id)
    .in("status", ["registration_open", "in_progress"]);

  const { count: totalRegistrations } = await supabase
    .from("tournament_registrations")
    .select("*", { count: "exact", head: true })
    .eq("tournaments.tournament_organizers.user_id", user.id);

  const stats = [
    {
      title: "Total Tournaments",
      value: totalTournaments || 0,
      icon: Trophy,
      color: "text-yellow-600",
      bg: "bg-yellow-100",
    },
    {
      title: "Active Tournaments",
      value: activeTournaments || 0,
      icon: Calendar,
      color: "text-green-600",
      bg: "bg-green-100",
    },
    {
      title: "Total Registrations",
      value: totalRegistrations || 0,
      icon: Users,
      color: "text-blue-600",
      bg: "bg-blue-100",
    },
  ];

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Organizer Dashboard</h1>
          <p className="text-gray-600 mt-1">Manage your tournaments and view statistics</p>
        </div>
        <Button asChild>
          <Link href="/organizer/tournaments/create">
            <Plus className="mr-2 h-4 w-4" />
            Create Tournament
          </Link>
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {stats.map((stat) => (
          <Card key={stat.title}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-500">{stat.title}</CardTitle>
              <stat.icon className={`h-4 w-4 ${stat.color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stat.value}</div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Recent Tournaments */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900">Your Tournaments</h2>
          <Button asChild variant="outline" size="sm">
            <Link href="/organizer/tournaments">
              View All <ArrowRight className="ml-2 h-4 w-4" />
            </Link>
          </Button>
        </div>

        {tournaments && tournaments.length > 0 ? (
          <div className="space-y-4">
            {tournaments.slice(0, 5).map((tournament) => (
              <Card key={tournament.id}>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className="p-3 bg-indigo-100 rounded-lg">
                        <Trophy className="h-6 w-6 text-indigo-600" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-900">{tournament.name}</h3>
                        <p className="text-sm text-gray-500">
                          {tournament.registration_open && "Registration Open"}{" "}
                          {tournament.registration_close && "· Closes " + new Date(tournament.registration_close).toLocaleDateString()}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center space-x-3">
                      <span
                        className={`px-2 py-1 text-xs font-medium rounded-full ${
                          tournament.status === "registration_open"
                            ? "bg-green-100 text-green-800"
                            : tournament.status === "in_progress"
                            ? "bg-blue-100 text-blue-800"
                            : tournament.status === "completed"
                            ? "bg-gray-100 text-gray-800"
                            : "bg-yellow-100 text-yellow-800"
                        }`}
                      >
                        {tournament.status.replace("_", " ")}
                      </span>
                      <Button asChild size="sm">
                        <Link href={`/organizer/tournaments/${tournament.id}`}>
                          Manage
                        </Link>
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          <Card>
            <CardContent className="p-12 text-center">
              <Trophy className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-4 text-lg font-medium text-gray-900">No tournaments yet</h3>
              <p className="mt-2 text-gray-500">Create your first tournament to get started</p>
              <Button asChild className="mt-4">
                <Link href="/organizer/tournaments/create">
                  Create Tournament
                </Link>
              </Button>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}