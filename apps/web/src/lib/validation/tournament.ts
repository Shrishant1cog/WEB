import { z } from "zod";

const requiredDate = z
  .string()
  .min(1, "Date is required")
  .refine((value) => !Number.isNaN(Date.parse(value)), "Invalid date");

const optionalDate = z
  .string()
  .optional()
  .transform((value) => (value && value.trim() !== "" ? value : undefined))
  .refine((value) => value === undefined || !Number.isNaN(Date.parse(value)), "Invalid date");

const optionalText = (max: number) =>
  z
    .string()
    .max(max)
    .optional()
    .transform((value) => (value && value.trim() !== "" ? value.trim() : undefined));

const checkbox = z
  .union([z.literal("on"), z.literal("true"), z.literal("false"), z.boolean(), z.undefined()])
  .transform((value) => value === "on" || value === "true" || value === true);

export const tournamentInputSchema = z
  .object({
    title: z.string().trim().min(3, "Title must be at least 3 characters").max(100),
    description: optionalText(5000),
    format: z.enum(["solo", "duo", "squad", "custom"]),
    mode: z.enum(["br", "cs", "tdm", "custom"]),
    map: optionalText(50),
    maxTeams: z.coerce.number().int().min(1, "Capacity must be at least 1").max(200),
    teamSize: z.coerce.number().int().refine((n) => [1, 2, 4].includes(n), "Roster size must be 1, 2 or 4"),
    registrationStartsAt: requiredDate,
    registrationEndsAt: requiredDate,
    tournamentStartsAt: requiredDate,
    tournamentEndsAt: optionalDate,
    withdrawalDeadline: optionalDate,
    prizePool: optionalText(200),
    rulesUrl: z
      .string()
      .optional()
      .transform((value) => (value && value.trim() !== "" ? value.trim() : undefined))
      .refine((value) => value === undefined || /^https?:\/\//.test(value), "Rules URL must start with http(s)://"),
    rulesText: optionalText(10000),
    contactInfo: optionalText(200),
    visibility: z.enum(["public", "private", "invite_only"]),
    waitlistEnabled: checkbox,
    requiresInGameId: checkbox,
  })
  .superRefine((data, ctx) => {
    const regStart = Date.parse(data.registrationStartsAt);
    const regEnd = Date.parse(data.registrationEndsAt);
    const starts = Date.parse(data.tournamentStartsAt);
    const ends = data.tournamentEndsAt ? Date.parse(data.tournamentEndsAt) : null;
    const withdrawal = data.withdrawalDeadline ? Date.parse(data.withdrawalDeadline) : null;

    if (regStart >= regEnd) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["registrationEndsAt"], message: "Registration must end after it opens" });
    }
    if (regEnd > starts) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["tournamentStartsAt"], message: "Tournament must start after registration closes" });
    }
    if (ends !== null && ends <= starts) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["tournamentEndsAt"], message: "Tournament end must be after it starts" });
    }
    if (withdrawal !== null && withdrawal > regEnd) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["withdrawalDeadline"], message: "Withdrawal deadline cannot be after registration closes" });
    }
    if (data.format === "solo" && data.teamSize !== 1) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["teamSize"], message: "Solo tournaments require a roster size of 1" });
    }
    if (data.format !== "solo" && data.teamSize === 1) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["teamSize"], message: "Team tournaments need a roster size above 1" });
    }
  });

export type TournamentInput = z.infer<typeof tournamentInputSchema>;

const iso = (value: string) =>
  new Date(value.endsWith("Z") ? value : `${value}Z`).toISOString();

export function toTournamentPayload(input: TournamentInput) {
  return {
    title: input.title,
    description: input.description ?? "",
    format: input.format,
    mode: input.mode,
    map: input.map ?? "",
    max_teams: input.maxTeams,
    team_size: input.format === "solo" ? 1 : input.teamSize,
    registration_starts_at: iso(input.registrationStartsAt),
    registration_ends_at: iso(input.registrationEndsAt),
    tournament_starts_at: iso(input.tournamentStartsAt),
    tournament_ends_at: input.tournamentEndsAt ? iso(input.tournamentEndsAt) : "",
    withdrawal_deadline: input.withdrawalDeadline ? iso(input.withdrawalDeadline) : "",
    prize_pool: input.prizePool ?? "",
    rules_url: input.rulesUrl ?? "",
    rules_text: input.rulesText ?? "",
    contact_info: input.contactInfo ?? "",
    visibility: input.visibility,
    waitlist_enabled: input.waitlistEnabled,
    eligibility: { requires_ingame_id: input.requiresInGameId },
  };
}

export const tournamentStatusSchema = z.enum([
  "draft",
  "published",
  "registration_open",
  "registration_closed",
  "in_progress",
  "completed",
  "cancelled",
]);

export const teamInputSchema = z.object({
  name: z.string().trim().min(3, "Team name must be at least 3 characters").max(50),
  tag: z
    .string()
    .optional()
    .transform((value) => (value && value.trim() !== "" ? value.trim() : undefined))
    .refine((value) => value === undefined || (value.length >= 2 && value.length <= 6), "Tag must be 2-6 characters"),
  description: optionalText(1000),
});

export const inviteInputSchema = z
  .object({
    email: z
      .string()
      .optional()
      .transform((value) => (value && value.trim() !== "" ? value.trim().toLowerCase() : undefined))
      .refine((value) => value === undefined || /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value), "Enter a valid email"),
    invitedUserId: z.string().uuid().optional(),
    expiresHours: z.coerce.number().int().min(1).max(168).default(72),
  })
  .refine((value) => value.email !== undefined || value.invitedUserId !== undefined, {
    message: "Provide an email address or player id",
    path: ["email"],
  });

export function firstIssue(error: z.ZodError): string {
  return error.issues[0]?.message ?? "Invalid input";
}
