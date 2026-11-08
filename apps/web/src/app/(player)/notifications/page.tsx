import Link from "next/link";
import { formatDistanceToNow } from "date-fns";
import { createServerSupabaseClient, getServerUser } from "@/lib/supabase/client";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-error";
import {
  markAllNotificationsReadAction,
  markNotificationReadAction,
  setNotificationPreferencesAction,
} from "@/lib/actions/notifications";

const CATEGORIES = [
  ["registration", "Registration"],
  ["waitlist", "Waitlist"],
  ["match", "Matches"],
  ["credentials", "Room credentials"],
  ["result", "Results"],
  ["dispute", "Disputes"],
  ["announcement", "Announcements"],
  ["moderation", "Moderation"],
  ["system", "Account & system"],
] as const;

export const metadata = { title: "Notifications" };

export default async function NotificationsPage() {
  const user = await getServerUser();
  const supabase = await createServerSupabaseClient();

  const [{ data: notifications }, { data: preferences }] = await Promise.all([
    supabase
      .from("notifications")
      .select("id, type, title, body, category, read_at, created_at, data")
      .eq("in_app_visible", true)
      .order("created_at", { ascending: false })
      .limit(100),
    supabase.from("notification_preferences").select("category, in_app, push, email"),
  ]);

  const rows = notifications ?? [];
  const prefMap = new Map((preferences ?? []).map((row) => [row.category, row]));
  const unread = rows.filter((row) => !row.read_at).length;

  return (
    <div className="space-y-8">
      <header className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-title-xl font-bold text-foreground">Notifications</h1>
          <p className="mt-1 text-body-md text-muted-foreground">
            {unread > 0 ? `${unread} unread` : "You are all caught up"} · {user?.email}
          </p>
        </div>
        {unread > 0 && (
          <ActionForm
            action={markAllNotificationsReadAction}
            submitLabel="Mark all read"
            pendingLabel="Marking…"
            variant="outline"
            size="sm"
          >
            <></>
          </ActionForm>
        )}
      </header>

      <section aria-labelledby="notification-list-heading">
        <h2 id="notification-list-heading" className="sr-only">
          Notification history
        </h2>
        {rows.length === 0 ? (
          <EmptyState
            icon="🔔"
            title="No notifications yet"
            message="Registration confirmations, match updates, results and announcements will appear here."
            action={
              <Button asChild variant="outline" size="sm">
                <Link href="/tournaments">Browse tournaments</Link>
              </Button>
            }
          />
        ) : (
          <ul className="space-y-3">
            {rows.map((notification) => {
              const data = (notification.data ?? {}) as Record<string, unknown>;
              const href =
                typeof data.tournament_id === "string"
                  ? `/tournaments/${data.tournament_id}`
                  : undefined;

              return (
                <li key={notification.id}>
                  <Card
                    className={
                      notification.read_at
                        ? "border-border"
                        : "border-primary/40 bg-primary/[0.04]"
                    }
                  >
                    <CardHeader className="p-4 pb-2">
                      <div className="flex flex-wrap items-start justify-between gap-2">
                        <div>
                          <CardTitle className="text-title-md">{notification.title}</CardTitle>
                          <p className="mt-1 text-label-sm uppercase tracking-wide text-muted-foreground">
                            {notification.category} ·{" "}
                            {formatDistanceToNow(new Date(notification.created_at), {
                              addSuffix: true,
                            })}
                          </p>
                        </div>
                        {!notification.read_at && (
                          <span className="rounded-full bg-primary px-2 py-1 text-label-sm font-semibold text-primary-foreground">
                            New
                          </span>
                        )}
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-3 p-4 pt-0">
                      {notification.body && (
                        <p className="text-body-sm text-muted-foreground">{notification.body}</p>
                      )}
                      <div className="flex flex-wrap items-center gap-3">
                        {href && (
                          <Button asChild variant="link" size="sm" className="px-0">
                            <Link href={href}>Open tournament</Link>
                          </Button>
                        )}
                        {!notification.read_at && (
                          <ActionForm
                            action={markNotificationReadAction}
                            submitLabel="Mark read"
                            pendingLabel="Saving…"
                            variant="ghost"
                            size="sm"
                          >
                            <input
                              type="hidden"
                              name="notificationId"
                              value={notification.id}
                            />
                          </ActionForm>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                </li>
              );
            })}
          </ul>
        )}
      </section>

      <section aria-labelledby="preferences-heading">
        <Card>
          <CardHeader>
            <CardTitle id="preferences-heading">Preferences by event type</CardTitle>
            <p className="text-body-sm text-muted-foreground">
              In-app notifications are always available in this centre. Push delivery is queued
              only when a device is registered. Email is off by default.
            </p>
          </CardHeader>
          <CardContent>
            <ActionForm
              action={setNotificationPreferencesAction}
              submitLabel="Save preferences"
              pendingLabel="Saving…"
              className="space-y-4"
            >
              <div className="overflow-x-auto">
                <table className="w-full min-w-[560px] text-left text-body-sm">
                  <thead>
                    <tr className="border-b text-label-sm uppercase tracking-wide text-muted-foreground">
                      <th scope="col" className="py-2 pr-4">Event type</th>
                      <th scope="col" className="px-3 py-2">In-app</th>
                      <th scope="col" className="px-3 py-2">Push</th>
                      <th scope="col" className="px-3 py-2">Email</th>
                    </tr>
                  </thead>
                  <tbody>
                    {CATEGORIES.map(([category, label]) => {
                      const pref = prefMap.get(category);
                      return (
                        <tr key={category} className="border-b last:border-0">
                          <th scope="row" className="py-3 pr-4 font-medium text-foreground">
                            {label}
                          </th>
                          {(["in_app", "push", "email"] as const).map((channel) => {
                            const id = `${channel}_${category}`;
                            const checked =
                              channel === "email"
                                ? Boolean(pref?.email)
                                : channel === "push"
                                  ? pref?.push ?? true
                                  : pref?.in_app ?? true;
                            return (
                              <td key={channel} className="px-3 py-3">
                                <label htmlFor={id} className="sr-only">
                                  {label} {channel}
                                </label>
                                <input
                                  id={id}
                                  name={id}
                                  type="checkbox"
                                  defaultChecked={checked}
                                  className="h-4 w-4 rounded border-input text-primary focus-visible:ring-2 focus-visible:ring-ring"
                                />
                              </td>
                            );
                          })}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </ActionForm>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
