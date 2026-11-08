import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export const metadata = { title: "Admin users" };

export default async function AdminUsersPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q = "" } = await searchParams;
  const supabase = await createServerSupabaseClient();
  const { data: users, error } = await supabase.rpc("admin_search_users", {
    p_query: q || null,
    p_limit: 50,
  });

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-title-xl font-bold">Users</h1>
        <p className="mt-1 text-body-sm text-muted-foreground">
          Search by display name, username or email. Account detail and suspension controls are
          available on each profile.
        </p>
      </header>

      <Card>
        <CardContent className="p-4">
          <form method="get" className="flex flex-wrap items-end gap-3">
            <div className="min-w-[240px] flex-1 space-y-2">
              <Label htmlFor="q">Search users</Label>
              <Input id="q" name="q" defaultValue={q} placeholder="Name, username or email" />
            </div>
            <Button type="submit">Search</Button>
            {q && (
              <Button asChild variant="ghost">
                <Link href="/admin/users">Clear</Link>
              </Button>
            )}
          </form>
        </CardContent>
      </Card>

      {error && (
        <Card>
          <CardHeader><CardTitle>Search failed</CardTitle></CardHeader>
          <CardContent className="text-body-sm text-muted-foreground">{error.message}</CardContent>
        </Card>
      )}

      <div className="overflow-x-auto rounded-xl border bg-card">
        <table className="w-full min-w-[760px] text-left text-body-sm">
          <thead className="border-b bg-muted/40 text-label-sm uppercase tracking-wide text-muted-foreground">
            <tr>
              <th scope="col" className="px-4 py-3">User</th>
              <th scope="col" className="px-4 py-3">Email</th>
              <th scope="col" className="px-4 py-3">Account</th>
              <th scope="col" className="px-4 py-3">Organizer</th>
              <th scope="col" className="px-4 py-3">Admin</th>
              <th scope="col" className="px-4 py-3"><span className="sr-only">Actions</span></th>
            </tr>
          </thead>
          <tbody>
            {(users ?? []).length === 0 ? (
              <tr>
                <td colSpan={6} className="px-4 py-10 text-center text-muted-foreground">
                  No users match this search.
                </td>
              </tr>
            ) : (
              (users ?? []).map((user) => (
                <tr key={user.user_id} className="border-b last:border-0">
                  <td className="px-4 py-3 font-medium text-foreground">{user.display_name}</td>
                  <td className="px-4 py-3 text-muted-foreground">{user.email ?? "—"}</td>
                  <td className="px-4 py-3 capitalize">{user.account_status}</td>
                  <td className="px-4 py-3 capitalize">{user.organizer_status ?? "—"}</td>
                  <td className="px-4 py-3">{user.is_platform_admin ? "Yes" : "—"}</td>
                  <td className="px-4 py-3 text-right">
                    <Button asChild size="sm" variant="outline">
                      <Link href={`/admin/users/${user.user_id}`}>Inspect</Link>
                    </Button>
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
