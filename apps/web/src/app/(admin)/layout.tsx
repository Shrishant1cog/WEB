import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { getUserPermissions, hasAdminAccess } from "@/lib/auth/permissions";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createServerSupabaseClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirect=/admin");
  }

  const permissions = await getUserPermissions(supabase, user.id);

  if (!hasAdminAccess(permissions)) {
    redirect("/dashboard?error=unauthorized");
  }

  return <>{children}</>;
}