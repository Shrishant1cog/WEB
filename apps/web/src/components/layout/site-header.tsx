import Link from "next/link";
import { getServerUser, createServerSupabaseClient } from "@/lib/supabase/client";
import { getUserPermissions } from "@/lib/auth/permissions";
import { signOutAction } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";

async function getUnreadCount(): Promise<number> {
  const supabase = await createServerSupabaseClient();
  const { count } = await supabase
    .from("notifications")
    .select("*", { count: "exact", head: true })
    .is("read_at", null)
    .eq("in_app_visible", true);
  return count ?? 0;
}

export async function SiteHeader() {
  const user = await getServerUser();
  const permissions = user ? await getUserPermissions(user.id) : null;
  const isOrganizer = permissions?.platformRole === "organizer";
  const isAdmin = Boolean(permissions?.platformAdminRole);
  const unread = user ? await getUnreadCount() : 0;

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-sm">
      <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-6">
          <Link href="/" className="text-title-lg font-bold text-primary" aria-label="FFT Home">
            FFT
          </Link>
          <nav className="hidden md:flex items-center gap-1 text-body-sm text-muted-foreground" aria-label="Main navigation">
            <Link href="/tournaments" className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors">
              Tournaments
            </Link>
            {user && (
              <>
                <Link href="/dashboard" className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors">
                  Dashboard
                </Link>
                <Link href="/my-teams" className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors">
                  My teams
                </Link>
                <Link href="/my-tournaments" className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors">
                  My entries
                </Link>
                <Link href="/organizer/dashboard" className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors">
                  {isOrganizer ? "Organizer" : "Host a tournament"}
                </Link>
                <Link href="/abuse" className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors">
                  Report abuse
                </Link>
                {isAdmin && (
                  <Link href="/admin" className="rounded-lg px-3 py-2 font-medium text-primary hover:bg-accent hover:text-foreground transition-colors">
                    Admin
                  </Link>
                )}
              </>
            )}
          </nav>
        </div>

        <div className="flex items-center gap-2">
          {user ? (
            <>
              <Link
                href="/notifications"
                aria-label={unread > 0 ? `Notifications, ${unread} unread` : "Notifications"}
                className="relative inline-flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              >
                <svg
                  className="h-5 w-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                  />
                </svg>
                {unread > 0 && (
                  <span className="absolute -right-1 -top-1 flex h-5 min-w-5 items-center justify-center rounded-full bg-primary px-1 text-[10px] font-bold text-primary-foreground">
                    {unread > 99 ? "99+" : unread}
                  </span>
                )}
              </Link>
              <span className="hidden text-body-sm text-muted-foreground sm:inline-flex items-center gap-2">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-primary font-medium">
                  {user.email?.charAt(0).toUpperCase() ?? "U"}
                </span>
                <span className="truncate max-w-[150px]">{user.email}</span>
              </span>
              <form action={signOutAction}>
                <Button type="submit" variant="ghost" size="sm" className="text-muted-foreground hover:text-foreground">
                  Sign out
                </Button>
              </form>
            </>
          ) : (
            <>
              <Button asChild variant="ghost" size="sm">
                <Link href="/login">Sign in</Link>
              </Button>
              <Button asChild size="sm">
                <Link href="/register">Create account</Link>
              </Button>
            </>
          )}
        </div>
      </div>
    </header>
  );
}

export function SiteFooter() {
  return (
    <footer className="border-t bg-muted/30">
      <div className="mx-auto max-w-7xl px-4 py-10">
        <div className="grid gap-8 md:grid-cols-4">
          <div className="space-y-3">
            <Link href="/" className="text-title-md font-bold text-primary" aria-label="FFT Home">
              FFT
            </Link>
            <p className="text-body-sm text-muted-foreground">
              Independent tournament management platform for Free Fire.
            </p>
          </div>
          <nav className="space-y-2" aria-label="Product">
            <h4 className="font-semibold text-foreground">Product</h4>
            <ul className="space-y-1">
              <li><Link href="/tournaments" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Browse Tournaments</Link></li>
              <li><Link href="/organizer/tournaments/create" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Host a Tournament</Link></li>
              <li><Link href="/my-teams" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">My Teams</Link></li>
            </ul>
          </nav>
          <nav className="space-y-2" aria-label="Legal">
            <h4 className="font-semibold text-foreground">Legal</h4>
            <ul className="space-y-1">
              <li><Link href="/terms" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Terms of Service</Link></li>
              <li><Link href="/privacy" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Privacy Policy</Link></li>
              <li><Link href="/fair-play" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Fair Play Policy</Link></li>
            </ul>
          </nav>
          <div className="space-y-2">
            <h4 className="font-semibold text-foreground">Community</h4>
            <ul className="space-y-1">
              <li><Link href="https://discord.gg/fft" target="_blank" rel="noopener noreferrer" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Discord</Link></li>
              <li><Link href="https://github.com/fft" target="_blank" rel="noopener noreferrer" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">GitHub</Link></li>
              <li><Link href="/contact" className="text-body-sm text-muted-foreground hover:text-foreground transition-colors">Contact</Link></li>
            </ul>
          </div>
        </div>
        <div className="mt-8 border-t pt-8 text-center text-body-sm text-muted-foreground">
          <p className="font-medium text-foreground">FFT is an independent tournament management platform.</p>
          <p className="mt-1">It is not affiliated with, endorsed by, or operated by Garena.</p>
        </div>
      </div>
    </footer>
  );
}