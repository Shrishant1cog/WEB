import { redirect } from "next/navigation";
import { getServerUser } from "@/lib/supabase/client";
import { SiteFooter, SiteHeader } from "@/components/layout/site-header";

export default async function PlayerLayout({ children }: { children: React.ReactNode }) {
  const user = await getServerUser();
  if (!user) redirect("/login");

  return (
    <div className="flex min-h-screen flex-col bg-gray-50">
      <SiteHeader />
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-8">{children}</main>
      <SiteFooter />
    </div>
  );
}
