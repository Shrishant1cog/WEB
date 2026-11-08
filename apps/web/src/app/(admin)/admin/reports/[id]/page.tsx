import Link from "next/link";
import { notFound } from "next/navigation";
import { formatDistanceToNow } from "date-fns";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { resolveReportAction, triageReportAction } from "@/lib/actions/admin";

export const metadata = { title: "Admin report detail" };

interface ReporterDetail {
  profile?: { display_name?: string; email?: string | null };
}

export default async function AdminReportDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createServerSupabaseClient();

  const [{ data: report, error }, { data: events }] = await Promise.all([
    supabase.from("abuse_reports").select("*").eq("id", id).single(),
    supabase
      .from("abuse_report_events")
      .select("id, event_type, from_status, to_status, note, created_at, actor_id")
      .eq("report_id", id)
      .order("created_at", { ascending: true }),
  ]);

  if (error || !report) notFound();

  const { data: reporter } = await supabase.rpc("admin_get_user", {
    p_user_id: report.reporter_id,
  });
  const reporterDetail = reporter as unknown as ReporterDetail | null;

  let evidence: Array<{ path: string; url: string | null }> = [];
  if ((report.evidence_paths ?? []).length > 0) {
    const { data: signed } = await supabase.storage
      .from("abuse-evidence")
      .createSignedUrls(report.evidence_paths, 3600);
    evidence = (signed ?? []).map((item) => ({
      path: item.path ?? "",
      url: item.signedUrl ?? null,
    }));
  }

  return (
    <div className="space-y-6">
      <div>
        <Button asChild variant="link" size="sm" className="px-0">
          <Link href="/admin/reports">← All reports</Link>
        </Button>
        <h1 className="text-title-xl font-bold capitalize">
          {report.category.replaceAll("_", " ")} report
        </h1>
        <p className="text-body-sm text-muted-foreground">
          {report.subject_type.replaceAll("_", " ")} · submitted{" "}
          {formatDistanceToNow(new Date(report.created_at), { addSuffix: true })} · severity{" "}
          {report.severity}
        </p>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader><CardTitle>Report</CardTitle></CardHeader>
          <CardContent className="space-y-3">
            <p className="whitespace-pre-wrap text-body-sm">{report.description}</p>
            <dl className="grid gap-2 text-body-sm sm:grid-cols-2">
              <div>
                <dt className="text-label-sm uppercase text-muted-foreground">Reporter</dt>
                <dd>{reporterDetail?.profile?.display_name ?? report.reporter_id}</dd>
              </div>
              <div>
                <dt className="text-label-sm uppercase text-muted-foreground">Reporter email</dt>
                <dd>{reporterDetail?.profile?.email ?? "—"}</dd>
              </div>
              <div>
                <dt className="text-label-sm uppercase text-muted-foreground">Tournament</dt>
                <dd>{report.tournament_id ?? "—"}</dd>
              </div>
              <div>
                <dt className="text-label-sm uppercase text-muted-foreground">Subject</dt>
                <dd>{report.subject_id ?? "—"}</dd>
              </div>
            </dl>
            {evidence.length > 0 && (
              <div>
                <h3 className="text-title-sm font-semibold">Evidence</h3>
                <ul className="mt-2 space-y-1 text-body-sm">
                  {evidence.map((item) => (
                    <li key={item.path}>
                      {item.url ? (
                        <a className="text-primary underline" href={item.url} target="_blank" rel="noopener noreferrer">
                          {item.path.split("/").pop()}
                        </a>
                      ) : (
                        <span className="text-muted-foreground">{item.path}</span>
                      )}
                    </li>
                  ))}
                </ul>
              </div>
            )}
            {report.resolution && (
              <p className="rounded-md bg-emerald-500/10 p-3 text-body-sm">
                <strong>Resolution:</strong> {report.resolution}
              </p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Audit history</CardTitle></CardHeader>
          <CardContent>
            <ol className="space-y-2 border-l pl-4 text-body-sm">
              {(events ?? []).map((event) => (
                <li key={event.id}>
                  <span className="font-medium capitalize">{event.event_type.replaceAll("_", " ")}</span>
                  {event.to_status ? ` → ${event.to_status}` : ""}
                  <span className="block text-label-sm text-muted-foreground">
                    {formatDistanceToNow(new Date(event.created_at), { addSuffix: true })}
                    {event.note ? ` · ${event.note}` : ""}
                  </span>
                </li>
              ))}
            </ol>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader><CardTitle>Triage</CardTitle></CardHeader>
          <CardContent>
            <ActionForm action={triageReportAction} submitLabel="Save triage">
              <input type="hidden" name="reportId" value={report.id} />
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="status">Status</Label>
                  <select
                    id="status"
                    name="status"
                    defaultValue={report.status}
                    className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm"
                  >
                    <option value="submitted">Submitted</option>
                    <option value="triaged">Triaged</option>
                    <option value="investigating">Investigating</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="severity">Severity</Label>
                  <select
                    id="severity"
                    name="severity"
                    defaultValue={report.severity}
                    className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
              </div>
              <div className="mt-3 space-y-2">
                <Label htmlFor="assignedAdminId">Assign to administrator (user ID, optional)</Label>
                <Input
                  id="assignedAdminId"
                  name="assignedAdminId"
                  defaultValue={report.assigned_admin_id ?? ""}
                />
              </div>
              <div className="mt-3 space-y-2">
                <Label htmlFor="note">Internal note</Label>
                <Input id="note" name="note" />
              </div>
            </ActionForm>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Resolution</CardTitle></CardHeader>
          <CardContent>
            <ActionForm action={resolveReportAction} submitLabel="Resolve report" variant="success">
              <input type="hidden" name="reportId" value={report.id} />
              <div className="space-y-2">
                <Label htmlFor="resolution">Resolution (shared with the reporter)</Label>
                <textarea
                  id="resolution"
                  name="resolution"
                  required
                  minLength={5}
                  rows={5}
                  className="w-full rounded-lg border border-input bg-background px-3 py-2 text-body-sm"
                />
              </div>
              <label className="mt-3 flex items-center gap-2 text-body-sm">
                <input type="checkbox" name="dismiss" className="h-4 w-4" />
                Dismiss instead of upholding
              </label>
            </ActionForm>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
