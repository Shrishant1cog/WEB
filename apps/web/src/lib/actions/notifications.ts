"use server";

import { revalidatePath } from "next/cache";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { humanizeDbError } from "@/lib/errors";

export type ActionState = { error?: string; success?: string } | null;

const CATEGORIES = [
  "registration",
  "waitlist",
  "match",
  "credentials",
  "result",
  "dispute",
  "announcement",
  "moderation",
  "system",
] as const;

async function currentUser() {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return { supabase, user };
}

export async function markNotificationReadAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const id = String(formData.get("notificationId") ?? "");
  if (!id) return { error: "Notification not found." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in to continue." };

  const { error } = await supabase.rpc("mark_notification_read", {
    p_notification_id: id,
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/notifications");
  revalidatePath("/dashboard");
  return { success: "Marked as read." };
}

export async function markAllNotificationsReadAction(
  _prev: ActionState,
  _formData: FormData
): Promise<ActionState> {
  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in to continue." };

  const { error } = await supabase.rpc("mark_all_notifications_read");
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/notifications");
  revalidatePath("/dashboard");
  return { success: "All notifications marked as read." };
}

export async function setNotificationPreferencesAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in to continue." };

  for (const category of CATEGORIES) {
    const { error } = await supabase.rpc("set_notification_preference", {
      p_category: category,
      p_in_app: formData.get(`in_app_${category}`) === "on",
      p_push: formData.get(`push_${category}`) === "on",
      p_email: formData.get(`email_${category}`) === "on",
    });
    if (error) return { error: humanizeDbError(error) };
  }

  revalidatePath("/notifications");
  return { success: "Notification preferences saved." };
}

export async function registerWebDeviceTokenAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const token = String(formData.get("token") ?? "").trim();
  if (token.length < 16) return { error: "That device token is not valid." };

  const { supabase, user } = await currentUser();
  if (!user) return { error: "Please sign in to continue." };

  const { error } = await supabase.rpc("register_device_token", {
    p_token: token,
    p_platform: "web",
  });
  if (error) return { error: humanizeDbError(error) };

  return { success: "Browser notifications enabled." };
}
