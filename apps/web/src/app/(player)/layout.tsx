import { redirect } from "next/navigation";
import { getServerUser } from "@/lib/supabase/client";
import { getAccountStatus } from "@/lib/auth/permissions";
import { SiteFooter, SiteHeader } from "@/components/layout/site-header";
import { AccountSuspendedNotice } from "@/components/layout/account-suspended";

export default async function PlayerLayout({ children }: { children: React.ReactNode }) {
  const user = await getServerUser();
  if (!user) redirect("/login");

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
