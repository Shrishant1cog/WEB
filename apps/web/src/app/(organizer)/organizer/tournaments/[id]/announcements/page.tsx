import Link from "next/link";
import { notFound } from "next/navigation";
import { requireUser } from "@/lib/auth/require-user";
import { getOrganizerTournamentIds, getTournamentById } from "@/lib/data/tournaments";
import { createAnnouncementAction, type ActionState } from "@/lib/actions/admin";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { formatDistanceToNow } from "date-fns";
import { createServerSupabaseClient } from "@/lib/supabase/client";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function OrganizerAnnouncementsPage({
  params,
}: PageProps) {
  const { id } = await params;
  const { user } = await requireUser(`/organizer/tournaments/${id}`);

  const tournament = await getTournamentById(id);
  if (!tournament) notFound();

  const organizerIds = await getOrganizerTournamentIds(user.id);
  if (!organizerIds.includes(id)) notFound();

  const supabase = await createServerSupabaseClient();
  const { data: announcements } = await supabase
    .from("tournament_announcements")
    .select("id, title, body, pinned, published_at, created_at")
    .eq("tournament_id", id)
    .order("pinned", { ascending: false })
    .order("published_at", { ascending: false });

  return (
    <div className="space-y-8">
      <header className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-title-xl font-bold text-foreground">
            Announcements
          </h1>
          <p className="mt-1 text-body-sm text-muted-foreground">
            Post updates for {tournament.title}. Confirmed participants are notified.
          </p>
        </div>
        <Link href={`/organizer/tournaments/${id}`} className="text-body-sm text-muted-foreground hover:text-foreground">
          ← Back to tournament
        </Link>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Post announcement</CardTitle>
        </CardHeader>
        <CardContent>
          <ActionForm
            action={createAnnouncementAction}
            submitLabel="Publish"
            pendingLabel="Publishing…"
            className="space-y-4"
          >
            <input type="hidden" name="tournamentId" value={id} />
            <div className="space-y-2">
              <Label htmlFor="announcement-title">Title</Label>
              <Input
                id="announcement-title"
                name="title"
                required
                maxLength={120}
                placeholder="e.g. Match schedule updated"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="announcement-body">Body</Label>
              <textarea
                id="announcement-body"
                name="body"
                required
                minLength={1}
                maxLength={4000}
                rows={4}
                className="w-full rounded-lg border border-input bg-background px-3 py-2 text-body-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </div>
            <label className="mt-2 flex items-center gap-2 text-body-sm">
              <input type="checkbox" name="pinned" className="h-4 w-4" />
              Pin this announcement to the top
            </label>
          </ActionForm>
        </CardContent>
      </Card>

      <section aria-labelledby="announcements-heading">
        <h2 id="announcements-heading" className="text-title-lg font-semibold text-foreground">
          Announcement history
        </h2>
        {(announcements ?? []).length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center text-body-sm text-muted-foreground">
              No announcements yet. Post your first update above.
            </CardContent>
          </Card>
        ) : (
          <ul className="space-y-4 divide-y">
            {(announcements ?? []).map((announcement) => (
              <li key={announcement.id}>
                <Card className="border-t-0 border-r-0 border-b-0 border-l-0 sm:border sm:rounded-xl">
                  <CardHeader className="p-4 pb-2">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                      <div>
                        <CardTitle className="text-title-md">{announcement.title}</CardTitle>
                        <p className="text-body-sm text-muted-foreground">
                          {formatDistanceToNow(new Date(announcement.published_at), {
                            addSuffix: true,
                          })} ·{" "}
                          <span
                            className={`capitalize inline-block px-2 py-0.5 rounded-md text-xs font-medium ${
                              announcement.pinned
                                ? "bg-amber-100 text-amber-800 border border-amber-200"
                                : "bg-muted text-muted-foreground border border-muted/30"
                            }`}
                          >
                            {announcement.pinned ? "Pinned" : "Standard"}
                          </span>
                        </p>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="p-4 pt-0">
                    <p className="whitespace-pre-wrap text-body-sm text-muted-foreground">
                      {announcement.body}
                    </p>
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
