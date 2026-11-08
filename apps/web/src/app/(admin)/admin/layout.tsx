import Link from "next/link";
import { redirect } from "next/navigation";
import { getServerUser } from "@/lib/supabase/client";
import { getPlatformAdminRole } from "@/lib/auth/permissions";
import { signOutAction } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";

const NAV = [
  ["/admin", "Overview"],
  ["/admin/users", "Users"],
  ["/admin/organizers", "Organizers"],
  ["/admin/tournaments", "Tournaments"],
  ["/admin/reports", "Abuse reports"],
  ["/admin/audit", "Audit logs"],
  ["/admin/settings", "Settings"],
] as const;

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = await getServerUser();
  if (!user) redirect("/login?redirect=/admin");

  const role = await getPlatformAdminRole();
  if (!role) redirect("/dashboard");

  return (
    <div className="flex min-h-screen flex-col bg-gray-100">
      <header className="border-b bg-slate-950 text-slate-100">
        <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-3">
          <div className="flex items-center gap-4">
            <Link href="/admin" className="text-title-md font-bold text-amber-400">
              FFT Admin
            </Link>
            <span className="rounded-full bg-amber-400/15 px-3 py-1 text-label-sm font-semibold uppercase tracking-wide text-amber-300">
              {role.replaceAll("_", " ")}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <Button asChild variant="ghost" size="sm" className="text-slate-300 hover:text-white">
              <Link href="/dashboard">Player view</Link>
            </Button>
            <form action={signOutAction}>
              <Button type="submit" variant="ghost" size="sm" className="text-slate-300 hover:text-white">
                Sign out
              </Button>
            </form>
          </div>
        </div>
        <nav aria-label="Administration" className="mx-auto max-w-7xl overflow-x-auto px-4">
          <ul className="flex gap-1 pb-2">
            {NAV.map(([href, label]) => (
              <li key={href}>
                <Link
                  href={href}
                  className="inline-flex whitespace-nowrap rounded-lg px-3 py-2 text-body-sm text-slate-300 transition-colors hover:bg-white/10 hover:text-white"
                >
                  {label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </header>
      <main className="mx-auto w-full max-w-7xl flex-1 px-4 py-8">{children}</main>
      <footer className="border-t bg-white/60 px-4 py-4 text-center text-label-sm text-muted-foreground">
        Platform administration actions are logged and audited.
      </footer>
    </div>
  );
}
