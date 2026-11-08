import Link from "next/link";
import { formatDistanceToNow } from "date-fns";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export const metadata = { title: "Admin abuse reports" };

export default async function AdminReportsPage() {
  const supabase = await createServerSupabaseClient();
  const { data: reports, error } = await supabase
    .from("abuse_reports")
    .select("id, category, subject_type, status, severity, reporter_id, assigned_admin_id, created_at, description")
    .order("created_at", { ascending: false })
    .limit(100);

  const open = (reports ?? []).filter((r) =>
    ["submitted", "triaged", "investigating"].includes(r.status)
  );

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-title-xl font-bold">Abuse reports</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          {open.length} open report{open.length === 1 ? "" : "s"} · reports are private to the
          reporter and platform staff.
        </p>
      </header>

      {error && (
        <Card>
          <CardHeader><CardTitle>Could not load reports</CardTitle></CardHeader>
          <CardContent className="text-body-sm text-muted-foreground">{error.message}</CardContent>
        </Card>
      )}

      <div className="space-y-3">
        {(reports ?? []).length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center text-body-sm text-muted-foreground">
              No abuse reports have been submitted.
            </CardContent>
          </Card>
        ) : (
          (reports ?? []).map((report) => (
            <Card key={report.id}>
              <CardHeader className="p-4 pb-2">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <CardTitle className="text-title-md capitalize">
                    {report.category.replaceAll("_", " ")}
                  </CardTitle>
                  <div className="flex flex-wrap gap-2">
                    <span className="rounded-full bg-muted px-3 py-1 text-label-sm font-semibold capitalize">
                      {report.status.replaceAll("_", " ")}
                    </span>
                    <span
                      className={`rounded-full px-3 py-1 text-label-sm font-semibold capitalize ${
                        report.severity === "critical" || report.severity === "high"
                          ? "bg-red-500/10 text-red-700"
                          : "bg-amber-500/10 text-amber-700"
                      }`}
                    >
                      {report.severity}
                    </span>
                  </div>
                </div>
                <p className="text-body-sm text-muted-foreground">
                  {report.subject_type.replaceAll("_", " ")} · submitted{" "}
                  {formatDistanceToNow(new Date(report.created_at), { addSuffix: true })}
                  {report.assigned_admin_id ? " · assigned" : " · unassigned"}
                </p>
              </CardHeader>
              <CardContent className="p-4 pt-0">
                <p className="line-clamp-2 text-body-sm text-muted-foreground">
                  {report.description}
                </p>
                <Button asChild size="sm" variant="outline" className="mt-3">
                  <Link href={`/admin/reports/${report.id}`}>Review report</Link>
                </Button>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
