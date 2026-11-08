import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { setOrganizerStatusAction } from "@/lib/actions/admin";

export const metadata = { title: "Admin organizers" };

const STATUSES = ["pending", "approved", "suspended"] as const;

export default async function AdminOrganizersPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>;
}) {
  const { status = "pending" } = await searchParams;
  const supabase = await createServerSupabaseClient();
  const { data: organizers, error } = await supabase.rpc("admin_list_organizers", {
    p_status: STATUSES.includes(status as (typeof STATUSES)[number]) ? status : null,
    p_limit: 100,
  });

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-title-xl font-bold">Organizer accounts</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          Approve or suspend organizer access. Approval only gates tournament creation when the
          <code className="mx-1 rounded bg-muted px-1">organizer_approval_required</code>
          feature flag is enabled.
        </p>
      </header>

      <nav aria-label="Filter organizers" className="flex flex-wrap gap-2">
        {STATUSES.map((value) => (
          <Button
            key={value}
            asChild
            size="sm"
            variant={value === status ? "default" : "outline"}
          >
            <Link href={`/admin/organizers?status=${value}`} className="capitalize">
              {value}
            </Link>
          </Button>
        ))}
      </nav>

      {error && (
        <Card>
          <CardHeader><CardTitle>Could not load organizers</CardTitle></CardHeader>
          <CardContent className="text-body-sm text-muted-foreground">{error.message}</CardContent>
        </Card>
      )}

      <div className="space-y-4">
        {(organizers ?? []).length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center text-body-sm text-muted-foreground">
              No organizers in this state.
            </CardContent>
          </Card>
        ) : (
          (organizers ?? []).map((organizer) => (
            <Card key={organizer.user_id}>
              <CardHeader className="p-4 pb-2">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <CardTitle className="text-title-md">{organizer.display_name}</CardTitle>
                  <span className="rounded-full bg-muted px-3 py-1 text-label-sm font-semibold capitalize">
                    {organizer.status}
                  </span>
                </div>
                <p className="text-body-sm text-muted-foreground">
                  {organizer.email ?? "No email"}
                  {organizer.organization_name ? ` · ${organizer.organization_name}` : ""}
                </p>
              </CardHeader>
              <CardContent className="flex flex-wrap items-end gap-3 p-4 pt-0">
                <ActionForm action={setOrganizerStatusAction} submitLabel="Approve" size="sm" variant="success">
                  <input type="hidden" name="userId" value={organizer.user_id} />
                  <input type="hidden" name="status" value="approved" />
                  <input type="hidden" name="organizationName" value={organizer.organization_name ?? ""} />
                </ActionForm>
                <ActionForm action={setOrganizerStatusAction} submitLabel="Suspend" size="sm" variant="destructive">
                  <input type="hidden" name="userId" value={organizer.user_id} />
                  <input type="hidden" name="status" value="suspended" />
                  <input type="hidden" name="organizationName" value={organizer.organization_name ?? ""} />
                </ActionForm>
                <Button asChild size="sm" variant="link">
                  <Link href={`/admin/users/${organizer.user_id}`}>Inspect user</Link>
                </Button>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
