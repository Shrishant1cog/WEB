import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/client";

export default async function PlayerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createServerSupabaseClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirect=/player");
  }

  return <>{children}</>;
}