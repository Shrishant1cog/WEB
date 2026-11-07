import Link from "next/link";
import { getServerUser } from "@/lib/supabase/client";
import { getUserPermissions } from "@/lib/auth/permissions";
import { signOutAction } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";

export async function SiteHeader() {
  const user = await getServerUser();
  const permissions = user ? await getUserPermissions(user.id) : null;
  const isOrganizer = permissions?.platformRole === "organizer";

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
              </>
            )}
          </nav>
        </div>

        <div className="flex items-center gap-2">
          {user ? (
            <>
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