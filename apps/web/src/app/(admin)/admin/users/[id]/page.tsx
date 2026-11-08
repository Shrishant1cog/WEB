import { notFound } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { getPlatformAdminRole } from "@/lib/auth/permissions";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  grantPlatformAdminAction,
  restoreUserAction,
  revokePlatformAdminAction,
  setOrganizerStatusAction,
  suspendUserAction,
} from "@/lib/actions/admin";

export const metadata = { title: "Admin user detail" };

interface UserDetail {
  profile: {
    id: string;
    display_name: string;
    username: string | null;
    email: string | null;
    in_game_name: string | null;
    account_status: string;
    created_at: string;
  };
  suspension: {
    status: string;
    suspended_at: string | null;
    reason: string | null;
  } | null;
  platform_admin_role: string | null;
  organizer: {
    status: string;
    organization_name: string | null;
    contact_note: string | null;
    suspended_at: string | null;
    suspension_reason: string | null;
  } | null;
  counts: {
    tournaments: number;
    registrations: number;
    abuse_reports_filed: number;
  };
}

export default async function AdminUserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase.rpc("admin_get_user", { p_user_id: id });
  if (error || !data) notFound();

  const detail = data as unknown as UserDetail;
  const currentRole = await getPlatformAdminRole();
  const suspended = detail.profile.account_status !== "active";

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-title-xl font-bold">{detail.profile.display_name}</h1>
        <p className="text-body-sm text-muted-foreground">
          {detail.profile.email ?? "No email"} · Joined{" "}
          {new Date(detail.profile.created_at).toLocaleDateString()}
        </p>
      </header>

      <div className="grid gap-4 md:grid-cols-3">
        {[
          ["Tournaments hosted", detail.counts.tournaments],
          ["Registrations", detail.counts.registrations],
          ["Reports filed", detail.counts.abuse_reports_filed],
        ].map(([label, value]) => (
          <Card key={String(label)}>
            <CardContent className="p-4">
              <p className="text-label-sm uppercase tracking-wide text-muted-foreground">{label}</p>
              <p className="mt-1 text-title-lg font-bold">{value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card>
        <CardHeader><CardTitle>Account status</CardTitle></CardHeader>
        <CardContent className="space-y-3">
          <p className="text-body-sm">
            Current status: <strong className="capitalize">{detail.profile.account_status}</strong>
            {detail.suspension?.reason ? ` — ${detail.suspension.reason}` : ""}
          </p>
          {suspended ? (
            <ActionForm action={restoreUserAction} submitLabel="Restore account" variant="success">
              <input type="hidden" name="userId" value={id} />
              <div className="space-y-2">
                <Label htmlFor="restore-note">Note (optional)</Label>
                <Input id="restore-note" name="note" placeholder="Reason for restoring access" />
              </div>
            </ActionForm>
          ) : (
            <ActionForm
              action={suspendUserAction}
              submitLabel="Suspend account"
              variant="destructive"
              confirmMessage="Suspend this account? The user will lose access to protected actions."
            >
              <input type="hidden" name="userId" value={id} />
              <div className="space-y-2">
                <Label htmlFor="suspend-reason">Suspension reason</Label>
                <Input id="suspend-reason" name="reason" required minLength={3} />
              </div>
            </ActionForm>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Organizer account</CardTitle></CardHeader>
        <CardContent className="space-y-3">
          <p className="text-body-sm">
            Status: <strong className="capitalize">{detail.organizer?.status ?? "not requested"}</strong>
            {detail.organizer?.organization_name ? ` — ${detail.organizer.organization_name}` : ""}
          </p>
          <ActionForm action={setOrganizerStatusAction} submitLabel="Update organizer status">
            <input type="hidden" name="userId" value={id} />
            <div className="grid gap-3 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="organizer-status">Status</Label>
                <select
                  id="organizer-status"
                  name="status"
                  defaultValue={detail.organizer?.status ?? "pending"}
                  className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm"
                >
                  <option value="pending">Pending</option>
                  <option value="approved">Approved</option>
                  <option value="suspended">Suspended</option>
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="organizer-name">Organization name</Label>
                <Input id="organizer-name" name="organizationName" defaultValue={detail.organizer?.organization_name ?? ""} />
              </div>
            </div>
            <div className="mt-3 space-y-2">
              <Label htmlFor="organizer-reason">Reason (for suspension)</Label>
              <Input id="organizer-reason" name="reason" />
            </div>
          </ActionForm>
        </CardContent>
      </Card>

      {currentRole === "super_admin" && (
        <Card>
          <CardHeader><CardTitle>Platform administrator role</CardTitle></CardHeader>
          <CardContent className="space-y-3">
            <p className="text-body-sm">
              Current role: <strong className="capitalize">{detail.platform_admin_role ?? "none"}</strong>
            </p>
            <div className="grid gap-4 lg:grid-cols-2">
              <ActionForm action={grantPlatformAdminAction} submitLabel="Grant or update role">
                <input type="hidden" name="userId" value={id} />
                <div className="space-y-2">
                  <Label htmlFor="admin-role">Role</Label>
                  <select
                    id="admin-role"
                    name="role"
                    defaultValue={detail.platform_admin_role ?? "support"}
                    className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm"
                  >
                    <option value="support">Support</option>
                    <option value="admin">Admin</option>
                    <option value="super_admin">Super admin</option>
                  </select>
                </div>
                <div className="mt-3 space-y-2">
                  <Label htmlFor="admin-notes">Notes</Label>
                  <Input id="admin-notes" name="notes" />
                </div>
              </ActionForm>
              <ActionForm
                action={revokePlatformAdminAction}
                submitLabel="Revoke administrator role"
                variant="destructive"
                confirmMessage="Revoke this user's platform administrator access?"
              >
                <input type="hidden" name="userId" value={id} />
              </ActionForm>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
