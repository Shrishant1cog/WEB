import { describe, it, expect } from "vitest";
import {
  tournamentInputSchema,
  toTournamentPayload,
  tournamentStatusSchema,
  teamInputSchema,
  inviteInputSchema,
  firstIssue,
} from "./tournament";

describe("tournamentInputSchema", () => {
  const validInput = {
    title: "Test Tournament",
    description: "A test tournament",
    format: "squad" as const,
    mode: "br" as const,
    map: "Bermuda",
    maxTeams: 32,
    teamSize: 4,
    registrationStartsAt: "2026-01-01T10:00:00Z",
    registrationEndsAt: "2026-01-07T10:00:00Z",
    tournamentStartsAt: "2026-01-08T10:00:00Z",
    tournamentEndsAt: "2026-01-10T10:00:00Z",
    withdrawalDeadline: "2026-01-06T10:00:00Z",
    prizePool: "10000",
    rulesUrl: "https://example.com/rules",
    rulesText: "Standard rules apply",
    contactInfo: "organizer@example.com",
    visibility: "public" as const,
    waitlistEnabled: true,
    requiresInGameId: false,
  };

  it("accepts a valid tournament input", () => {
    const result = tournamentInputSchema.safeParse(validInput);
    expect(result.success).toBe(true);
  });

  it("rejects title shorter than 3 characters", () => {
    const input = { ...validInput, title: "AB" };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("at least 3");
    }
  });

  it("rejects title longer than 100 characters", () => {
    const input = { ...validInput, title: "A".repeat(101) };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects invalid format", () => {
    const input = { ...validInput, format: "invalid" as any };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects invalid mode", () => {
    const input = { ...validInput, mode: "invalid" as any };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects maxTeams below 1", () => {
    const input = { ...validInput, maxTeams: 0 };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("at least 1");
    }
  });

  it("rejects maxTeams above 200", () => {
    const input = { ...validInput, maxTeams: 201 };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects invalid teamSize", () => {
    const input = { ...validInput, teamSize: 3 };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("1, 2 or 4");
    }
  });

  it("rejects solo format with teamSize !== 1", () => {
    const input = { ...validInput, format: "solo" as const, teamSize: 4 };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Solo tournaments require a roster size of 1");
    }
  });

  it("rejects team format with teamSize === 1", () => {
    const input = { ...validInput, format: "squad" as const, teamSize: 1 };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Team tournaments need a roster size above 1");
    }
  });

  it("rejects registrationEndsAt before registrationStartsAt", () => {
    const input = {
      ...validInput,
      registrationStartsAt: "2026-01-07T10:00:00Z",
      registrationEndsAt: "2026-01-01T10:00:00Z",
    };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Registration must end after it opens");
    }
  });

  it("rejects tournamentStartsAt before registrationEndsAt", () => {
    const input = {
      ...validInput,
      registrationEndsAt: "2026-01-08T10:00:00Z",
      tournamentStartsAt: "2026-01-07T10:00:00Z",
    };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Tournament must start after registration closes");
    }
  });

  it("rejects tournamentEndsAt before tournamentStartsAt", () => {
    const input = {
      ...validInput,
      tournamentStartsAt: "2026-01-10T10:00:00Z",
      tournamentEndsAt: "2026-01-08T10:00:00Z",
    };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Tournament end must be after it starts");
    }
  });

  it("rejects withdrawalDeadline after registrationEndsAt", () => {
    const input = {
      ...validInput,
      registrationEndsAt: "2026-01-07T10:00:00Z",
      withdrawalDeadline: "2026-01-08T10:00:00Z",
    };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Withdrawal deadline cannot be after registration closes");
    }
  });

  it("rejects invalid rulesUrl", () => {
    const input = { ...validInput, rulesUrl: "not-a-url" };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("http(s)://");
    }
  });

  it("accepts valid rulesUrl", () => {
    const input = { ...validInput, rulesUrl: "https://example.com/rules" };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });

  it("accepts optional fields as undefined", () => {
    const input = { ...validInput, description: undefined, map: undefined };
    const result = tournamentInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });
});

describe("toTournamentPayload", () => {
  const validInput = {
    title: "Test Tournament",
    description: "A test tournament",
    format: "squad" as const,
    mode: "br" as const,
    map: "Bermuda",
    maxTeams: 32,
    teamSize: 4,
    registrationStartsAt: "2026-01-01T10:00:00Z",
    registrationEndsAt: "2026-01-07T10:00:00Z",
    tournamentStartsAt: "2026-01-08T10:00:00Z",
    tournamentEndsAt: "2026-01-10T10:00:00Z",
    withdrawalDeadline: "2026-01-06T10:00:00Z",
    prizePool: "10000",
    rulesUrl: "https://example.com/rules",
    rulesText: "Standard rules apply",
    contactInfo: "organizer@example.com",
    visibility: "public" as const,
    waitlistEnabled: true,
    requiresInGameId: false,
  };

  it("serializes all fields correctly", () => {
    const payload = toTournamentPayload(validInput);
    expect(payload.title).toBe("Test Tournament");
    expect(payload.format).toBe("squad");
    expect(payload.mode).toBe("br");
    expect(payload.max_teams).toBe(32);
    expect(payload.team_size).toBe(4);
    expect(payload.registration_starts_at).toBe("2026-01-01T10:00:00.000Z");
    expect(payload.registration_ends_at).toBe("2026-01-07T10:00:00.000Z");
    expect(payload.tournament_starts_at).toBe("2026-01-08T10:00:00.000Z");
    expect(payload.tournament_ends_at).toBe("2026-01-10T10:00:00.000Z");
    expect(payload.withdrawal_deadline).toBe("2026-01-06T10:00:00.000Z");
    expect(payload.prize_pool).toBe("10000");
    expect(payload.rules_url).toBe("https://example.com/rules");
    expect(payload.rules_text).toBe("Standard rules apply");
    expect(payload.contact_info).toBe("organizer@example.com");
    expect(payload.visibility).toBe("public");
    expect(payload.waitlist_enabled).toBe(true);
    expect(payload.eligibility).toEqual({ requires_ingame_id: false });
  });

  it("forces team_size to 1 for solo format", () => {
    const input = { ...validInput, format: "solo" as const, teamSize: 4 };
    const payload = toTournamentPayload(input);
    expect(payload.team_size).toBe(1);
  });

  it("omits empty optional fields", () => {
    const input = {
      ...validInput,
      description: "",
      map: "",
      prizePool: "",
      rulesUrl: "",
      rulesText: "",
      contactInfo: "",
      tournamentEndsAt: undefined,
      withdrawalDeadline: undefined,
    };
    const payload = toTournamentPayload(input);
    expect(payload.description).toBe("");
    expect(payload.map).toBe("");
    expect(payload.prize_pool).toBe("");
    expect(payload.rules_url).toBe("");
    expect(payload.rules_text).toBe("");
    expect(payload.contact_info).toBe("");
    expect(payload.tournament_ends_at).toBe("");
    expect(payload.withdrawal_deadline).toBe("");
  });
});

describe("tournamentStatusSchema", () => {
  it("accepts valid statuses", () => {
    const validStatuses = [
      "draft",
      "published",
      "registration_open",
      "registration_closed",
      "in_progress",
      "completed",
      "cancelled",
    ];
    for (const status of validStatuses) {
      const result = tournamentStatusSchema.safeParse(status);
      expect(result.success).toBe(true);
    }
  });

  it("rejects invalid status", () => {
    const result = tournamentStatusSchema.safeParse("invalid");
    expect(result.success).toBe(false);
  });
});

describe("teamInputSchema", () => {
  it("accepts valid team input", () => {
    const input = { name: "Alpha Squad", tag: "AL", description: "Test team" };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });

  it("rejects short name", () => {
    const input = { name: "AB", tag: "AL" };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects long name", () => {
    const input = { name: "A".repeat(51), tag: "AL" };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects short tag", () => {
    const input = { name: "Alpha", tag: "A" };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects long tag", () => {
    const input = { name: "Alpha", tag: "TOOLONG" };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("accepts missing tag", () => {
    const input = { name: "Alpha Squad" };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });

  it("trims whitespace", () => {
    const input = { name: "  Alpha Squad  ", tag: "  AL  " };
    const result = teamInputSchema.safeParse(input);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.name).toBe("Alpha Squad");
      expect(result.data.tag).toBe("AL");
    }
  });
});

describe("inviteInputSchema", () => {
  it("accepts email only", () => {
    const input = { email: "player@example.com", expiresHours: 72 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });

  it("accepts invitedUserId only", () => {
    const input = { invitedUserId: "123e4567-e89b-12d3-a456-426614174000", expiresHours: 72 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });

  it("accepts both email and invitedUserId", () => {
    const input = {
      email: "player@example.com",
      invitedUserId: "123e4567-e89b-12d3-a456-426614174000",
      expiresHours: 72,
    };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(true);
  });

  it("rejects missing both email and invitedUserId", () => {
    const input = { expiresHours: 72 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(firstIssue(result.error)).toContain("Provide an email address or player id");
    }
  });

  it("rejects invalid email", () => {
    const input = { email: "not-an-email", expiresHours: 72 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects expiresHours below 1", () => {
    const input = { email: "player@example.com", expiresHours: 0 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("rejects expiresHours above 168", () => {
    const input = { email: "player@example.com", expiresHours: 169 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(false);
  });

  it("defaults expiresHours to 72", () => {
    const input = { email: "player@example.com" };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.expiresHours).toBe(72);
    }
  });

  it("normalizes email to lowercase", () => {
    const input = { email: "PLAYER@EXAMPLE.COM", expiresHours: 72 };
    const result = inviteInputSchema.safeParse(input);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.email).toBe("player@example.com");
    }
  });
});