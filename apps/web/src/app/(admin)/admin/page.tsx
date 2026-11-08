import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export const metadata = { title: "Admin overview" };

interface Metrics {
  generated_at: string;
  users: { total: number; active: number; suspended: number; new_24h: number };
  organizers: { pending: number; approved: number; suspended: number };
  tournaments: { total: number; active: number; completed: number };
  abuse_reports: { open: number; resolved_24h: number };
  notifications: {
    last_24h: number;
    unread: number;
    push_pending: number;
    push_dead: number;
    scheduled_due: number;
  };
  settings: {
    organizer_approval_required: boolean;
    abuse_reporting_enabled: boolean;
    push_notifications_enabled: boolean;
    maintenance_mode: boolean;
  };
}

function Metric({ label, value, hint }: { label: string; value: number | string; hint?: string }) {
  return (
    <div className="rounded-lg border bg-card p-4">
      <p className="text-label-sm uppercase tracking-wide text-muted-foreground">{label}</p>
      <p className="mt-1 text-title-xl font-bold text-foreground">{value}</p>
      {hint && <p className="mt-1 text-label-sm text-muted-foreground">{hint}</p>}
    </div>
  );
}

export default async function AdminOverviewPage() {
  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase.rpc("admin_platform_metrics");

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Metrics unavailable</CardTitle>
        </CardHeader>
        <CardContent className="text-body-sm text-muted-foreground">
          {error.message}
        </CardContent>
      </Card>
    );
  }

  const metrics = data as unknown as Metrics;

  return (
    <div className="space-y-8">
      <header>
        <h1 className="text-title-xl font-bold text-foreground">Platform overview</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          Generated {new Date(metrics.generated_at).toLocaleString()}
        </p>
      </header>

      <section aria-labelledby="users-heading" className="space-y-3">
        <h2 id="users-heading" className="text-title-lg font-semibold">Users</h2>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <Metric label="Total" value={metrics.users.total} />
          <Metric label="Active" value={metrics.users.active} />
          <Metric label="Suspended" value={metrics.users.suspended} />
          <Metric label="New (24h)" value={metrics.users.new_24h} />
        </div>
      </section>

      <section aria-labelledby="ops-heading" className="space-y-3">
        <h2 id="ops-heading" className="text-title-lg font-semibold">Operations</h2>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <Metric label="Tournaments" value={metrics.tournaments.total} hint={`${metrics.tournaments.active} active`} />
          <Metric label="Open abuse reports" value={metrics.abuse_reports.open} hint={`${metrics.abuse_reports.resolved_24h} resolved (24h)`} />
          <Metric label="Notifications (24h)" value={metrics.notifications.last_24h} hint={`${metrics.notifications.unread} unread`} />
          <Metric label="Push queue" value={metrics.notifications.push_pending} hint={`${metrics.notifications.push_dead} dead letters`} />
        </div>
      </section>

      <section aria-labelledby="system-heading" className="space-y-3">
        <h2 id="system-heading" className="text-title-lg font-semibold">System status</h2>
        <Card>
          <CardContent className="grid gap-3 p-4 sm:grid-cols-2 lg:grid-cols-4">
            {[
              ["Organizer approval required", metrics.settings.organizer_approval_required],
              ["Abuse reporting enabled", metrics.settings.abuse_reporting_enabled],
              ["Push delivery enabled", metrics.settings.push_notifications_enabled],
              ["Maintenance mode", metrics.settings.maintenance_mode],
            ].map(([label, enabled]) => (
              <div key={String(label)} className="flex items-center justify-between gap-3 rounded-md border p-3">
                <span className="text-body-sm text-foreground">{label}</span>
                <span
                  className={`rounded-full px-2 py-1 text-label-sm font-semibold ${
                    enabled ? "bg-emerald-500/10 text-emerald-700" : "bg-slate-500/10 text-slate-600"
                  }`}
                >
                  {enabled ? "On" : "Off"}
                </span>
              </div>
            ))}
          </CardContent>
        </Card>
      </section>

      <section className="flex flex-wrap gap-3">
        <Button asChild variant="outline" size="sm">
          <Link href="/admin/reports">Review abuse reports</Link>
        </Button>
        <Button asChild variant="outline" size="sm">
          <Link href="/admin/organizers">Approve organizers</Link>
        </Button>
        <Button asChild variant="outline" size="sm">
          <Link href="/admin/audit">Search audit logs</Link>
        </Button>
      </section>

      <p className="text-label-sm text-muted-foreground">
        Scheduled notifications due: {metrics.notifications.scheduled_due}. Push delivery is
        decoupled from in-app notifications, so failures never block core flows.
      </p>
    </div>
  );
}
