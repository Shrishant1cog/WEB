import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { getPlatformAdminRole } from "@/lib/auth/permissions";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { revokePlatformAdminAction, setPlatformSettingAction } from "@/lib/actions/admin";

export const metadata = { title: "Admin settings" };

const KNOWN_SETTINGS: Record<string, { label: string; description: string }> = {
  organizer_approval_required: {
    label: "Require organizer approval",
    description: "Block tournament creation until an administrator approves the organizer.",
  },
  abuse_reporting_enabled: {
    label: "Enable abuse reporting",
    description: "Allow players and organizers to submit abuse reports.",
  },
  push_notifications_enabled: {
    label: "Enable push delivery",
    description: "Queue FCM push delivery. Leave off until credentials are configured.",
  },
  maintenance_mode: {
    label: "Maintenance mode",
    description: "Show the platform maintenance notice.",
  },
};

function boolValue(value: unknown): boolean {
  if (typeof value === "boolean") return value;
  return value === "true";
}

export default async function AdminSettingsPage() {
  const supabase = await createServerSupabaseClient();
  const [settingsResult, adminsResult, role] = await Promise.all([
    supabase.from("platform_settings").select("key, value, description, is_public, updated_at").order("key"),
    supabase
      .from("platform_admins")
      .select("user_id, role, granted_at, revoked_at, notes")
      .is("revoked_at", null)
      .order("granted_at"),
    getPlatformAdminRole(),
  ]);

  const settings = settingsResult.data ?? [];
  const admins = adminsResult.data ?? [];
  const isSuperAdmin = role === "super_admin";

  return (
    <div className="space-y-8">
      <header>
        <h1 className="text-title-xl font-bold">Platform settings</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          Feature flags and operational configuration. Every change is written to the audit log.
        </p>
      </header>

      {settingsResult.error && (
        <Card>
          <CardHeader><CardTitle>Could not load settings</CardTitle></CardHeader>
          <CardContent className="text-body-sm text-muted-foreground">
            {settingsResult.error.message}
          </CardContent>
        </Card>
      )}

      <section aria-labelledby="flags-heading" className="space-y-3">
        <h2 id="flags-heading" className="text-title-lg font-semibold">Feature flags</h2>
        <div className="grid gap-4 lg:grid-cols-2">
          {settings.map((setting) => {
            const known = KNOWN_SETTINGS[setting.key];
            const enabled = boolValue(setting.value);
            return (
              <Card key={setting.key}>
                <CardHeader className="p-4 pb-2">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <CardTitle className="text-title-md">
                      {known?.label ?? setting.key}
                    </CardTitle>
                    <span
                      className={`rounded-full px-3 py-1 text-label-sm font-semibold ${
                        enabled ? "bg-emerald-500/10 text-emerald-700" : "bg-slate-500/10 text-slate-600"
                      }`}
                    >
                      {enabled ? "On" : "Off"}
                    </span>
                  </div>
                  <p className="text-body-sm text-muted-foreground">
                    {known?.description ?? setting.description ?? "Custom platform setting."}
                  </p>
                  <p className="font-mono text-label-sm text-muted-foreground">
                    {setting.key} · {setting.is_public ? "public" : "private"}
                  </p>
                </CardHeader>
                <CardContent className="p-4 pt-0">
                  <ActionForm
                    action={setPlatformSettingAction}
                    submitLabel={enabled ? "Disable" : "Enable"}
                    size="sm"
                    variant={enabled ? "destructive" : "default"}
                  >
                    <input type="hidden" name="key" value={setting.key} />
                    <input type="hidden" name="kind" value="boolean" />
                    <input type="hidden" name="value" value={enabled ? "false" : "true"} />
                    <input type="hidden" name="isPublic" value={setting.is_public ? "on" : ""} />
                    <input
                      type="hidden"
                      name="description"
                      value={known?.description ?? setting.description ?? ""}
                    />
                  </ActionForm>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </section>

      <section aria-labelledby="custom-heading" className="space-y-3">
        <h2 id="custom-heading" className="text-title-lg font-semibold">Add or update a setting</h2>
        <Card>
          <CardContent className="p-4">
            <ActionForm action={setPlatformSettingAction} submitLabel="Save setting">
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="setting-key">Key</Label>
                  <Input
                    id="setting-key"
                    name="key"
                    required
                    pattern="[a-z0-9_.]{2,80}"
                    placeholder="feature_flag_name"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="setting-kind">Value type</Label>
                  <select
                    id="setting-kind"
                    name="kind"
                    defaultValue="boolean"
                    className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm"
                  >
                    <option value="boolean">Boolean</option>
                    <option value="number">Number</option>
                    <option value="json">JSON</option>
                  </select>
                </div>
              </div>
              <div className="mt-3 space-y-2">
                <Label htmlFor="setting-value">Value</Label>
                <Input id="setting-value" name="value" required placeholder="true" />
              </div>
              <div className="mt-3 space-y-2">
                <Label htmlFor="setting-description">Description</Label>
                <Input id="setting-description" name="description" />
              </div>
              <label className="mt-3 flex items-center gap-2 text-body-sm">
                <input type="checkbox" name="isPublic" className="h-4 w-4" />
                Publish this setting to clients
              </label>
            </ActionForm>
          </CardContent>
        </Card>
      </section>

      <section aria-labelledby="admins-heading" className="space-y-3">
        <h2 id="admins-heading" className="text-title-lg font-semibold">Platform administrators</h2>
        <Card>
          <CardContent className="p-4">
            {adminsResult.error ? (
              <p className="text-body-sm text-muted-foreground">{adminsResult.error.message}</p>
            ) : admins.length === 0 ? (
              <p className="text-body-sm text-muted-foreground">No active administrators.</p>
            ) : (
              <ul className="divide-y">
                {admins.map((admin) => (
                  <li
                    key={admin.user_id}
                    className="flex flex-wrap items-center justify-between gap-2 py-3"
                  >
                    <div>
                      <p className="font-mono text-body-sm">{admin.user_id}</p>
                      <p className="text-label-sm capitalize text-muted-foreground">
                        {admin.role.replaceAll("_", " ")} · granted{" "}
                        {new Date(admin.granted_at).toLocaleDateString()}
                        {admin.notes ? ` · ${admin.notes}` : ""}
                      </p>
                    </div>
                    <div className="flex items-center gap-2">
                      <Button asChild size="sm" variant="outline">
                        <Link href={`/admin/users/${admin.user_id}`}>Inspect</Link>
                      </Button>
                      {isSuperAdmin && (
                        <ActionForm
                          action={revokePlatformAdminAction}
                          submitLabel="Revoke"
                          size="sm"
                          variant="destructive"
                          confirmMessage="Revoke this administrator role?"
                          className="[&>button]:mt-0"
                        >
                          <input type="hidden" name="userId" value={admin.user_id} />
                        </ActionForm>
                      )}
                    </div>
                  </li>
                ))}
              </ul>
            )}
            <p className="mt-3 text-label-sm text-muted-foreground">
              Grant or change roles from a user&apos;s detail page. Only super administrators can
              grant or revoke administrator roles.
            </p>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
