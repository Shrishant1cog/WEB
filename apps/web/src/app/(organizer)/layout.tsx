import { redirect } from "next/navigation";
import { getServerUser } from "@/lib/supabase/client";
import { getAccountStatus } from "@/lib/auth/permissions";
import { SiteFooter, SiteHeader } from "@/components/layout/site-header";
import { AccountSuspendedNotice } from "@/components/layout/account-suspended";

/**
 * Any authenticated user may open the organizer area: hosting a tournament is
 * how an account becomes an organizer. Every write is additionally authorized
 * server-side by the Phase 3 RPCs (ownership of the specific tournament) and
 * organizer approval is enforced when the feature flag is enabled.
 */
export default async function OrganizerLayout({ children }: { children: React.ReactNode }) {
  const user = await getServerUser();
  if (!user) redirect("/login?redirect=/organizer/dashboard");

  const accountStatus = await getAccountStatus();
  const restricted = accountStatus === "suspended" || accountStatus === "banned";

  return (
    <div className="flex min-h-screen flex-col bg-gray-50">
      <SiteHeader />
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-8">
        {restricted && (
          <div className="mb-6">
            <AccountSuspendedNotice status={accountStatus} />
          </div>
        )}
        {children}
      </main>
      <SiteFooter />
    </div>
  );
}
