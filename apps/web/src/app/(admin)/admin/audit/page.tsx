import { createServerSupabaseClient } from "@/lib/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export const metadata = { title: "Admin audit logs" };

export default async function AdminAuditPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; action?: string }>;
}) {
  const { q = "", action = "" } = await searchParams;
  const supabase = await createServerSupabaseClient();
  const { data: logs, error } = await supabase.rpc("admin_search_audit_logs", {
    p_query: q || null,
    p_action: action || null,
    p_limit: 100,
  });

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-title-xl font-bold">Audit logs</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          Sensitive administrative actions are append-only. Search by action, resource type or
          resource ID.
        </p>
      </header>

      <Card>
        <CardContent className="p-4">
          <form method="get" className="flex flex-wrap items-end gap-3">
            <div className="min-w-[240px] flex-1 space-y-2">
              <Label htmlFor="q">Search</Label>
              <Input id="q" name="q" defaultValue={q} placeholder="Action, resource type or ID" />
            </div>
            <div className="min-w-[200px] space-y-2">
              <Label htmlFor="action">Exact action</Label>
              <Input id="action" name="action" defaultValue={action} placeholder="user.suspended" />
            </div>
            <Button type="submit">Search</Button>
          </form>
        </CardContent>
      </Card>

      {error && (
        <Card>
          <CardHeader><CardTitle>Could not load audit logs</CardTitle></CardHeader>
          <CardContent className="text-body-sm text-muted-foreground">{error.message}</CardContent>
        </Card>
      )}

      <div className="overflow-x-auto rounded-xl border bg-card">
        <table className="w-full min-w-[820px] text-left text-body-sm">
          <thead className="border-b bg-muted/40 text-label-sm uppercase tracking-wide text-muted-foreground">
            <tr>
              <th scope="col" className="px-4 py-3">When</th>
              <th scope="col" className="px-4 py-3">Actor</th>
              <th scope="col" className="px-4 py-3">Action</th>
              <th scope="col" className="px-4 py-3">Resource</th>
              <th scope="col" className="px-4 py-3">Details</th>
            </tr>
          </thead>
          <tbody>
            {(logs ?? []).length === 0 ? (
              <tr>
                <td colSpan={5} className="px-4 py-10 text-center text-muted-foreground">
                  No matching audit entries.
                </td>
              </tr>
            ) : (
              (logs ?? []).map((log) => (
                <tr key={log.id} className="border-b align-top last:border-0">
                  <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                    {new Date(log.created_at).toLocaleString()}
                  </td>
                  <td className="px-4 py-3 font-mono text-label-sm">{log.user_id ?? "system"}</td>
                  <td className="px-4 py-3 font-medium">{log.action}</td>
                  <td className="px-4 py-3 text-muted-foreground">
                    {log.resource_type}
                    {log.resource_id ? <span className="block font-mono text-label-sm">{log.resource_id}</span> : null}
                  </td>
                  <td className="px-4 py-3">
                    <details>
                      <summary className="cursor-pointer text-label-sm text-primary">View</summary>
                      <pre className="mt-2 max-w-md overflow-x-auto rounded bg-muted p-2 text-label-sm">
                        {JSON.stringify({ old: log.old_data, new: log.new_data }, null, 2)}
                      </pre>
                    </details>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
