import { redirect } from "next/navigation";
import { getServerUser } from "@/lib/supabase/client";
import { SiteFooter, SiteHeader } from "@/components/layout/site-header";

/**
 * Any authenticated user may open the organizer area: hosting a tournament is
 * how an account becomes an organizer. Every write is additionally authorized
 * server-side by the Phase 3 RPCs (ownership of the specific tournament).
 */
export default async function OrganizerLayout({ children }: { children: React.ReactNode }) {
  const user = await getServerUser();
  if (!user) redirect("/login?redirect=/organizer/dashboard");

  return (
    <div className="flex min-h-screen flex-col bg-gray-50">
      <SiteHeader />
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-8">{children}</main>
      <SiteFooter />
    </div>
  );
}
