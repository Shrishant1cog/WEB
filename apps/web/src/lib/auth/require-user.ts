import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/client";

export async function requireUser(redirectTo: string) {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect(`/login?redirect=${encodeURIComponent(redirectTo)}`);
  }

  return { supabase, user };
}
