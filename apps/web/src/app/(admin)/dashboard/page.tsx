import { createServerSupabaseClient } from "@/lib/supabase/client";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Users, Shield, Database, Settings, Trophy, AlertTriangle, ArrowRight } from "lucide-react";

export default async function AdminDashboardPage() {
  const supabase = createServerSupabaseClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  // Get platform stats
  const [
    { count: totalUsers },
    { count: totalTournaments },
    { count: totalTeams },
    { count: totalMatches },
    { count: pendingModeration },
  ] = await Promise.all([
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase.from("tournaments").select("*", { count: "exact", head: true }),
    supabase.from("teams").select("*", { count: "exact", head: true }),
    supabase.from("matches").select("*", { count: "exact", head: true }),
    supabase.from("audit_logs").select("*", { count: "exact", head: true }).eq("action", "moderation_review"),
  ]);

  const stats = [
    {
      title: "Total Users",
      value: totalUsers || 0,
      icon: Users,
      color: "text-blue-600",
      bg: "bg-blue-100",
      href: "/admin/users",
    },
    {
      title: "Total Tournaments",
      value: totalTournaments || 0,
      icon: Trophy,
      color: "text-yellow-600",
      bg: "bg-yellow-100",
      href: "/admin/tournaments",
    },
    {
      title: "Total Teams",
      value: totalTeams || 0,
      icon: Users,
      color: "text-green-600",
      bg: "bg-green-100",
      href: "/admin/teams",
    },
    {
      title: "Total Matches",
      value: totalMatches || 0,
      icon: Database,
      color: "text-purple-600",
      bg: "bg-purple-100",
      href: "/admin/matches",
    },
    {
      title: "Pending Moderation",
      value: pendingModeration || 0,
      icon: AlertTriangle,
      color: "text-red-600",
      bg: "bg-red-100",
      href: "/admin/moderation",
    },
  ];

  return (
    <div className="p-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
        <p className="text-gray-600 mt-1">Platform administration and moderation</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
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

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          {
            title: "User Management",
            description: "View and manage all platform users",
            icon: Users,
            href: "/admin/users",
            color: "text-blue-600 bg-blue-100",
          },
          {
            title: "Tournament Oversight",
            description: "Monitor all tournaments and matches",
            icon: Trophy,
            href: "/admin/tournaments",
            color: "text-yellow-600 bg-yellow-100",
          },
          {
            title: "Moderation Queue",
            description: "Review reported content and disputes",
            icon: Shield,
            href: "/admin/moderation",
            color: "text-red-600 bg-red-100",
          },
          {
            title: "Platform Settings",
            description: "Configure platform-wide settings",
            icon: Settings,
            href: "/admin/settings",
            color: "text-gray-600 bg-gray-100",
          },
        ].map((action) => (
          <Card key={action.title} className="hover:shadow-md transition-shadow cursor-pointer">
            <CardContent className="p-6">
              <div className={`p-3 rounded-lg ${action.color}`}>
                <action.icon className="h-6 w-6" />
              </div>
              <h3 className="mt-4 font-semibold text-gray-900">{action.title}</h3>
              <p className="mt-1 text-sm text-gray-500">{action.description}</p>
              <a
                href={action.href}
                className="mt-4 inline-flex items-center text-sm font-medium text-indigo-600 hover:text-indigo-500"
              >
                Open <ArrowRight className="ml-1 h-4 w-4" />
              </a>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}