import { formatDistanceToNow } from "date-fns";
import { createServerSupabaseClient, getServerUser } from "@/lib/supabase/client";
import { AbuseReportForm } from "@/components/abuse/report-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-error";

export const metadata = { title: "Report abuse" };

const STATUS_STYLES: Record<string, string> = {
  submitted: "bg-slate-500/10 text-slate-600",
  triaged: "bg-amber-500/10 text-amber-700",
  investigating: "bg-cyan-500/10 text-cyan-700",
  resolved: "bg-emerald-500/10 text-emerald-700",
  dismissed: "bg-slate-500/10 text-slate-600",
};

export default async function AbusePage() {
  const user = await getServerUser();
  const supabase = await createServerSupabaseClient();

  const { data: reports } = await supabase
    .from("abuse_reports")
    .select("id, category, subject_type, status, severity, description, created_at, resolution")
    .eq("reporter_id", user?.id ?? "")
    .order("created_at", { ascending: false });

  const reportIds = (reports ?? []).map((report) => report.id);
  const { data: events } = reportIds.length
    ? await supabase
        .from("abuse_report_events")
        .select("report_id, event_type, to_status, note, created_at")
        .in("report_id", reportIds)
        .order("created_at", { ascending: true })
    : { data: [] };

  const eventsByReport = new Map<
    string,
    Array<{
      report_id: string;
      event_type: string;
      to_status: string | null;
      note: string | null;
      created_at: string;
    }>
  >();
  for (const event of events ?? []) {
    const list = eventsByReport.get(event.report_id) ?? [];
    list.push(event);
    eventsByReport.set(event.report_id, list);
  }

  return (
    <div className="space-y-8">
      <header>
        <h1 className="text-title-xl font-bold text-foreground">Report abuse</h1>
        <p className="mt-1 max-w-3xl text-body-md text-muted-foreground">
          Report harassment, cheating, match fixing or suspicious tournament activity. Reports
          are private: only you and platform administrators can see them.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Submit a report</CardTitle>
        </CardHeader>
        <CardContent>
          <AbuseReportForm />
        </CardContent>
      </Card>

      <section aria-labelledby="my-reports-heading" className="space-y-4">
        <h2 id="my-reports-heading" className="text-title-lg font-semibold text-foreground">
          My reports
        </h2>
        {(reports ?? []).length === 0 ? (
          <EmptyState
            icon="🛡️"
            title="No reports filed"
            message="Reports you submit will appear here with their review history."
          />
        ) : (
          <ul className="space-y-4">
            {(reports ?? []).map((report) => (
              <li key={report.id}>
                <Card>
                  <CardHeader className="p-4 pb-2">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <CardTitle className="text-title-md capitalize">
                        {report.category.replaceAll("_", " ")} ·{" "}
                        <span className="text-body-sm font-normal text-muted-foreground">
                          {report.subject_type.replaceAll("_", " ")}
                        </span>
                      </CardTitle>
                      <span
                        className={`rounded-full px-3 py-1 text-label-sm font-semibold capitalize ${
                          STATUS_STYLES[report.status] ?? STATUS_STYLES.submitted
                        }`}
                      >
                        {report.status.replaceAll("_", " ")}
                      </span>
                    </div>
                    <p className="text-label-sm text-muted-foreground">
                      Submitted{" "}
                      {formatDistanceToNow(new Date(report.created_at), { addSuffix: true })} ·
                      Severity {report.severity}
                    </p>
                  </CardHeader>
                  <CardContent className="space-y-3 p-4 pt-0">
                    <p className="text-body-sm text-muted-foreground">{report.description}</p>
                    {report.resolution && (
                      <p className="rounded-md bg-muted p-3 text-body-sm">
                        <span className="font-semibold">Resolution:</span> {report.resolution}
                      </p>
                    )}
                    <details className="text-body-sm">
                      <summary className="cursor-pointer font-medium text-foreground">
                        Audit history
                      </summary>
                      <ol className="mt-2 space-y-1 border-l pl-4 text-muted-foreground">
                        {(eventsByReport.get(report.id) ?? []).map((event, index) => (
                          <li key={`${event.created_at}-${index}`}>
                            <span className="font-medium capitalize">
                              {event.event_type.replaceAll("_", " ")}
                            </span>
                            {event.to_status ? ` → ${event.to_status}` : ""} ·{" "}
                            {formatDistanceToNow(new Date(event.created_at), { addSuffix: true })}
                            {event.note ? ` — ${event.note}` : ""}
                          </li>
                        ))}
                      </ol>
                    </details>
                  </CardContent>
                </Card>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
