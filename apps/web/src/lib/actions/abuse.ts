"use server";

import { revalidatePath } from "next/cache";
import { createServerSupabaseClient } from "@/lib/supabase/client";
import { humanizeDbError } from "@/lib/errors";
import { abuseReportSchema, firstIssue } from "@/lib/validation/abuse";

export type ActionState = { error?: string; success?: string } | null;

function evidencePaths(formData: FormData): string[] {
  return formData
    .getAll("evidencePaths")
    .map((value) => String(value).trim())
    .filter((value) => value.length > 0 && value.length <= 512)
    .slice(0, 10);
}

export async function submitAbuseReportAction(
  _prev: ActionState,
  formData: FormData
): Promise<ActionState> {
  const parsed = abuseReportSchema.safeParse({
    category: formData.get("category"),
    subjectType: formData.get("subjectType"),
    subjectId: formData.get("subjectId"),
    tournamentId: formData.get("tournamentId"),
    description: formData.get("description"),
  });
  if (!parsed.success) return { error: firstIssue(parsed.error) };

  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Please sign in to continue." };

  const { error } = await supabase.rpc("submit_abuse_report", {
    p_category: parsed.data.category,
    p_subject_type: parsed.data.subjectType,
    p_description: parsed.data.description,
    p_subject_id: parsed.data.subjectId ?? null,
    p_tournament_id: parsed.data.tournamentId ?? null,
    p_evidence_paths: evidencePaths(formData),
  });
  if (error) return { error: humanizeDbError(error) };

  revalidatePath("/abuse");
  revalidatePath("/notifications");
  return { success: "Report submitted. Platform staff will review it." };
}
