import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { getUserPermissions, hasOrganizerAccess } from "@/lib/auth/permissions";

export default async function OrganizerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createServerSupabaseClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirect=/organizer");
  }

  const permissions = await getUserPermissions(supabase, user.id);

  if (!hasOrganizerAccess(permissions)) {
    redirect("/dashboard?error=unauthorized");
  }

  return <>{children}</>;
}