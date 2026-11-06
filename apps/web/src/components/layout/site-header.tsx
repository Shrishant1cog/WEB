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
    <header className="border-b bg-white">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-6">
          <Link href="/" className="text-lg font-bold text-indigo-700">
            FFT
          </Link>
          <nav className="flex items-center gap-4 text-sm text-gray-600" aria-label="Main navigation">
            <Link href="/tournaments" className="hover:text-indigo-700">
              Tournaments
            </Link>
            {user && (
              <>
                <Link href="/dashboard" className="hover:text-indigo-700">
                  Dashboard
                </Link>
                <Link href="/my-teams" className="hover:text-indigo-700">
                  My teams
                </Link>
                <Link href="/my-tournaments" className="hover:text-indigo-700">
                  My entries
                </Link>
                <Link href="/organizer/dashboard" className="hover:text-indigo-700">
                  {isOrganizer ? "Organizer" : "Host a tournament"}
                </Link>
              </>
            )}
          </nav>
        </div>

        <div className="flex items-center gap-2">
          {user ? (
            <>
              <span className="hidden text-sm text-gray-500 sm:inline">
                {user.email}
              </span>
              <form action={signOutAction}>
                <Button type="submit" variant="outline" size="sm">
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
    <footer className="mt-16 border-t bg-gray-50">
      <div className="mx-auto max-w-6xl px-4 py-8 text-sm text-gray-600">
        <p className="font-medium text-gray-800">
          FFT is an independent tournament management platform.
        </p>
        <p className="mt-1">
          It is not affiliated with, endorsed by, or operated by Garena.
        </p>
      </div>
    </footer>
  );
}
