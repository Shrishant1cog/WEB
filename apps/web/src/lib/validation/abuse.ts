import { z } from "zod";

export const ABUSE_CATEGORIES = [
  ["harassment", "Harassment or threats"],
  ["cheating", "Cheating or hacks"],
  ["match_fixing", "Match fixing"],
  ["inappropriate_content", "Inappropriate content"],
  ["impersonation", "Impersonation"],
  ["spam", "Spam"],
  ["other", "Other"],
] as const;

export const ABUSE_SUBJECT_TYPES = [
  ["user", "A player"],
  ["tournament", "A tournament"],
  ["team", "A team"],
  ["match", "A match"],
  ["result", "A result"],
  ["dispute", "A dispute"],
  ["other", "Something else"],
] as const;

export const abuseReportSchema = z.object({
  category: z.enum(ABUSE_CATEGORIES.map(([value]) => value) as [string, ...string[]]),
  subjectType: z.enum(ABUSE_SUBJECT_TYPES.map(([value]) => value) as [string, ...string[]]),
  subjectId: z
    .string()
    .optional()
    .transform((value) => (value && value.trim() !== "" ? value.trim() : undefined))
    .refine(
      (value) => value === undefined || /^[0-9a-f-]{36}$/i.test(value),
      "Subject ID must be a UUID"
    ),
  tournamentId: z
    .string()
    .optional()
    .transform((value) => (value && value.trim() !== "" ? value.trim() : undefined))
    .refine(
      (value) => value === undefined || /^[0-9a-f-]{36}$/i.test(value),
      "Tournament ID must be a UUID"
    ),
  description: z.string().trim().min(10, "Describe the issue in at least 10 characters").max(4000),
});

export function firstIssue(error: z.ZodError): string {
  return error.issues[0]?.message ?? "Please check the form.";
}
