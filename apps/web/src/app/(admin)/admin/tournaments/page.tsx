import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  assignModeratorAction,
  removeModeratorAction,
} from "@/lib/actions/admin";

export const metadata = { title: "Admin tournaments" };

export default async function AdminTournamentsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; moderators?: string }>;
}) {
  const { q = "", moderators: moderatorTournament } = await searchParams;
  const supabase = await createServerSupabaseClient();
  const [{ data: tournaments, error }, moderatorResult] = await Promise.all([
    supabase.rpc("admin_list_tournaments", { p_query: q || null, p_limit: 50 }),
    moderatorTournament
      ? supabase.rpc("admin_list_moderators", { p_tournament_id: moderatorTournament })
      : Promise.resolve({ data: [], error: null }),
  ]);

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-title-xl font-bold">Tournament oversight</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          Review tournaments and assign tournament-scoped moderators. Moderators cannot participate
          in the tournaments they moderate.
        </p>
      </header>

      <Card>
        <CardContent className="p-4">
          <form method="get" className="flex flex-wrap items-end gap-3">
            <div className="min-w-[240px] flex-1 space-y-2">
              <Label htmlFor="q">Search tournaments</Label>
              <Input id="q" name="q" defaultValue={q} placeholder="Tournament or organizer" />
            </div>
            <Button type="submit">Search</Button>
            {q && (
              <Button asChild variant="ghost"><Link href="/admin/tournaments">Clear</Link></Button>
            )}
          </form>
        </CardContent>
      </Card>

      {error && (
        <Card>
          <CardHeader><CardTitle>Could not load tournaments</CardTitle></CardHeader>
          <CardContent className="text-body-sm text-muted-foreground">{error.message}</CardContent>
        </Card>
      )}

      <div className="space-y-4">
        {(tournaments ?? []).map((tournament) => (
          <Card key={tournament.tournament_id}>
            <CardHeader className="p-4 pb-2">
              <div className="flex flex-wrap items-start justify-between gap-2">
                <div>
                  <CardTitle className="text-title-md">{tournament.title}</CardTitle>
                  <p className="text-body-sm text-muted-foreground">
                    {tournament.organizer_name} · {tournament.format} · {tournament.registered_count}/
                    {tournament.max_teams} entries
                  </p>
                </div>
                <span className="rounded-full bg-muted px-3 py-1 text-label-sm font-semibold capitalize">
                  {tournament.status.replaceAll("_", " ")}
                </span>
              </div>
            </CardHeader>
            <CardContent className="space-y-4 p-4 pt-0">
              <div className="flex flex-wrap gap-3">
                <Button asChild size="sm" variant="outline">
                  <Link href={`/tournaments/${tournament.tournament_id}`}>Public page</Link>
                </Button>
                <Button asChild size="sm" variant="outline">
                  <Link href={`/admin/tournaments?moderators=${tournament.tournament_id}`}>
                    Moderators
                  </Link>
                </Button>
              </div>
              <ActionForm
                action={assignModeratorAction}
                submitLabel="Assign moderator"
                size="sm"
                className="flex flex-wrap items-end gap-3"
              >
                <input type="hidden" name="tournamentId" value={tournament.tournament_id} />
                <div className="min-w-[260px] flex-1 space-y-2">
                  <Label htmlFor={`moderator-${tournament.tournament_id}`}>User ID</Label>
                  <Input
                    id={`moderator-${tournament.tournament_id}`}
                    name="userId"
                    required
                    placeholder="User UUID"
                  />
                </div>
              </ActionForm>

              {moderatorTournament === tournament.tournament_id && (
                <div className="rounded-lg border p-3">
                  <h3 className="text-title-sm font-semibold">Assigned moderators</h3>
                  {moderatorResult.error && (
                    <p className="text-body-sm text-red-700">{moderatorResult.error.message}</p>
                  )}
                  {!moderatorResult.error && (moderatorResult.data ?? []).length === 0 && (
                    <p className="text-body-sm text-muted-foreground">No moderators assigned.</p>
                  )}
                  <ul className="mt-2 space-y-2">
                    {(moderatorResult.data ?? []).map((moderator) => (
                      <li key={moderator.user_id} className="flex flex-wrap items-center justify-between gap-2">
                        <span className="text-body-sm">
                          {moderator.display_name}{" "}
                          <span className="text-muted-foreground">{moderator.email ?? moderator.user_id}</span>
                        </span>
                        <ActionForm
                          action={removeModeratorAction}
                          submitLabel="Remove"
                          size="sm"
                          variant="destructive"
                        >
                          <input type="hidden" name="tournamentId" value={tournament.tournament_id} />
                          <input type="hidden" name="userId" value={moderator.user_id} />
                        </ActionForm>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
