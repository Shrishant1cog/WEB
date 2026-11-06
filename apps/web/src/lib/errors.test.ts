import { describe, it, expect } from "vitest";
import { humanizeDbError } from "./errors";

describe("humanizeDbError", () => {
  it("maps AUTH_REQUIRED", () => {
    const msg = humanizeDbError({ message: "AUTH_REQUIRED: please sign in" });
    expect(msg).toBe("Please sign in to continue. (please sign in)");
  });

  it("maps NOT_TOURNAMENT_ORGANIZER", () => {
    const msg = humanizeDbError({ message: "NOT_TOURNAMENT_ORGANIZER: access denied" });
    expect(msg).toBe("You do not have permission to manage this tournament. (access denied)");
  });

  it("maps TOURNAMENT_NOT_FOUND", () => {
    const msg = humanizeDbError({ message: "TOURNAMENT_NOT_FOUND" });
    expect(msg).toBe("Tournament not found.");
  });

  it("maps TOURNAMENT_NOT_EDITABLE", () => {
    const msg = humanizeDbError({ message: "TOURNAMENT_NOT_EDITABLE: too late" });
    expect(msg).toBe("This tournament can no longer be edited. (too late)");
  });

  it("maps INVALID_STATUS_TRANSITION", () => {
    const msg = humanizeDbError({ message: "INVALID_STATUS_TRANSITION" });
    expect(msg).toBe("That status change is not allowed from the current state.");
  });

  it("maps INVALID_TOURNAMENT_DATES", () => {
    const msg = humanizeDbError({ message: "INVALID_TOURNAMENT_DATES" });
    expect(msg).toBe("Registration must end before the tournament starts.");
  });

  it("maps REGISTRATION_NOT_OPEN", () => {
    const msg = humanizeDbError({ message: "REGISTRATION_NOT_OPEN" });
    expect(msg).toBe("Registration is not open for this tournament.");
  });

  it("maps REGISTRATION_WINDOW_CLOSED", () => {
    const msg = humanizeDbError({ message: "REGISTRATION_WINDOW_CLOSED" });
    expect(msg).toBe("Registration is outside the configured window.");
  });

  it("maps ORGANIZER_CANNOT_PARTICIPATE", () => {
    const msg = humanizeDbError({ message: "ORGANIZER_CANNOT_PARTICIPATE" });
    expect(msg).toBe("Organizers cannot enter their own tournament.");
  });

  it("maps TEAM_REQUIRED_FOR_SQUAD", () => {
    const msg = humanizeDbError({ message: "TEAM_REQUIRED_FOR_SQUAD" });
    expect(msg).toBe("Squad tournaments require a complete team.");
  });

  it("maps TEAM_NOT_ALLOWED_FOR_SOLO", () => {
    const msg = humanizeDbError({ message: "TEAM_NOT_ALLOWED_FOR_SOLO" });
    expect(msg).toBe("Solo tournaments do not accept teams.");
  });

  it("maps TEAM_NOT_FOUND", () => {
    const msg = humanizeDbError({ message: "TEAM_NOT_FOUND" });
    expect(msg).toBe("Team not found.");
  });

  it("maps ONLY_CAPTAIN_CAN_REGISTER", () => {
    const msg = humanizeDbError({ message: "ONLY_CAPTAIN_CAN_REGISTER" });
    expect(msg).toBe("Only the team captain can register the team.");
  });

  it("maps ROSTER_INCOMPLETE", () => {
    const msg = humanizeDbError({ message: "ROSTER_INCOMPLETE: expected 4 members, found 2" });
    expect(msg).toBe("Your roster is not complete for this tournament. (expected 4 members, found 2)");
  });

  it("maps ELIGIBILITY_INGAME_ID_REQUIRED", () => {
    const msg = humanizeDbError({ message: "ELIGIBILITY_INGAME_ID_REQUIRED: Player1" });
    expect(msg).toBe("Every member must add a Free Fire in-game UID before registering. (Player1)");
  });

  it("maps PLAYER_ACCOUNT_DELETED", () => {
    const msg = humanizeDbError({ message: "PLAYER_ACCOUNT_DELETED" });
    expect(msg).toBe("One of the selected players has a deleted account.");
  });

  it("maps PLAYER_ALREADY_REGISTERED", () => {
    const msg = humanizeDbError({ message: "PLAYER_ALREADY_REGISTERED" });
    expect(msg).toBe("One of the selected players is already registered in this tournament.");
  });

  it("maps ALREADY_REGISTERED", () => {
    const msg = humanizeDbError({ message: "ALREADY_REGISTERED" });
    expect(msg).toBe("You are already registered in this tournament.");
  });

  it("maps ENTRY_TYPE_CONFLICT", () => {
    const msg = humanizeDbError({ message: "ENTRY_TYPE_CONFLICT" });
    expect(msg).toBe("You already have an entry of a different type in this tournament.");
  });

  it("maps TOURNAMENT_FULL", () => {
    const msg = humanizeDbError({ message: "TOURNAMENT_FULL" });
    expect(msg).toBe("This tournament is full and the waitlist is disabled.");
  });

  it("maps WITHDRAWAL_CLOSED", () => {
    const msg = humanizeDbError({ message: "WITHDRAWAL_CLOSED" });
    expect(msg).toBe("Withdrawals are closed because registration has ended.");
  });

  it("maps WITHDRAWAL_DEADLINE_PASSED", () => {
    const msg = humanizeDbError({ message: "WITHDRAWAL_DEADLINE_PASSED" });
    expect(msg).toBe("The withdrawal deadline has passed.");
  });

  it("maps ENTRY_NOT_FOUND", () => {
    const msg = humanizeDbError({ message: "ENTRY_NOT_FOUND" });
    expect(msg).toBe("Registration not found.");
  });

  it("maps NOT_ENTRY_OWNER", () => {
    const msg = humanizeDbError({ message: "NOT_ENTRY_OWNER" });
    expect(msg).toBe("You can only withdraw your own registration.");
  });

  it("maps INVALID_TEAM_NAME", () => {
    const msg = humanizeDbError({ message: "INVALID_TEAM_NAME" });
    expect(msg).toBe("Team name must be between 3 and 50 characters.");
  });

  it("maps ONLY_CAPTAIN_CAN_INVITE", () => {
    const msg = humanizeDbError({ message: "ONLY_CAPTAIN_CAN_INVITE" });
    expect(msg).toBe("Only the team captain can invite players.");
  });

  it("maps ONLY_CAPTAIN_CAN_REMOVE", () => {
    const msg = humanizeDbError({ message: "ONLY_CAPTAIN_CAN_REMOVE" });
    expect(msg).toBe("Only the team captain can remove members.");
  });

  it("maps ONLY_CAPTAIN_CAN_TRANSFER", () => {
    const msg = humanizeDbError({ message: "ONLY_CAPTAIN_CAN_TRANSFER" });
    expect(msg).toBe("Only the team captain can transfer captaincy.");
  });

  it("maps ONLY_CAPTAIN_CAN_DISSOLVE", () => {
    const msg = humanizeDbError({ message: "ONLY_CAPTAIN_CAN_DISSOLVE" });
    expect(msg).toBe("Only the team captain can dissolve the team.");
  });

  it("maps ONLY_CAPTAIN_CAN_REVOKE", () => {
    const msg = humanizeDbError({ message: "ONLY_CAPTAIN_CAN_REVOKE" });
    expect(msg).toBe("Only the team captain can revoke invitations.");
  });

  it("maps INVITE_TARGET_REQUIRED", () => {
    const msg = humanizeDbError({ message: "INVITE_TARGET_REQUIRED" });
    expect(msg).toBe("Provide a player or an email address to invite.");
  });

  it("maps INVALID_INVITE_EXPIRY", () => {
    const msg = humanizeDbError({ message: "INVALID_INVITE_EXPIRY" });
    expect(msg).toBe("Invitation expiry must be between 1 and 168 hours.");
  });

  it("maps INVITE_RATE_LIMIT", () => {
    const msg = humanizeDbError({ message: "INVITE_RATE_LIMIT" });
    expect(msg).toBe("Too many invitations for this team. Try again later.");
  });

  it("maps TEAM_FULL", () => {
    const msg = humanizeDbError({ message: "TEAM_FULL" });
    expect(msg).toBe("This team is full.");
  });

  it("maps ALREADY_TEAM_MEMBER", () => {
    const msg = humanizeDbError({ message: "ALREADY_TEAM_MEMBER" });
    expect(msg).toBe("That player is already on the team.");
  });

  it("maps INVALID_INVITATION", () => {
    const msg = humanizeDbError({ message: "INVALID_INVITATION" });
    expect(msg).toBe("This invitation is invalid or has already been used.");
  });

  it("maps INVITATION_EXPIRED", () => {
    const msg = humanizeDbError({ message: "INVITATION_EXPIRED" });
    expect(msg).toBe("This invitation has expired.");
  });

  it("maps INVITATION_FOR_ANOTHER_USER", () => {
    const msg = humanizeDbError({ message: "INVITATION_FOR_ANOTHER_USER" });
    expect(msg).toBe("This invitation was issued to a different player.");
  });

  it("maps INVITATION_NOT_FOUND", () => {
    const msg = humanizeDbError({ message: "INVITATION_NOT_FOUND" });
    expect(msg).toBe("Invitation not found.");
  });

  it("maps MEMBER_NOT_FOUND", () => {
    const msg = humanizeDbError({ message: "MEMBER_NOT_FOUND" });
    expect(msg).toBe("Team member not found.");
  });

  it("maps NOT_TEAM_MEMBER", () => {
    const msg = humanizeDbError({ message: "NOT_TEAM_MEMBER" });
    expect(msg).toBe("You are not a member of this team.");
  });

  it("maps NEW_CAPTAIN_MUST_BE_MEMBER", () => {
    const msg = humanizeDbError({ message: "NEW_CAPTAIN_MUST_BE_MEMBER" });
    expect(msg).toBe("The new captain must already be on the team.");
  });

  it("maps USE_LEAVE_TEAM", () => {
    const msg = humanizeDbError({ message: "USE_LEAVE_TEAM" });
    expect(msg).toBe("Use 'Leave team' to remove yourself.");
  });

  it("maps TRANSFER_CAPTAINCY_REQUIRED", () => {
    const msg = humanizeDbError({ message: "TRANSFER_CAPTAINCY_REQUIRED" });
    expect(msg).toBe("Transfer captaincy before leaving the team.");
  });

  it("maps TEAM_HAS_ACTIVE_REGISTRATION", () => {
    const msg = humanizeDbError({ message: "TEAM_HAS_ACTIVE_REGISTRATION" });
    expect(msg).toBe("Dissolve is blocked while the team has an active registration.");
  });

  it("maps Postgres unique violation (23505)", () => {
    const msg = humanizeDbError({ code: "23505", message: "duplicate key value violates unique constraint" });
    expect(msg).toBe("That record already exists.");
  });

  it("maps Postgres permission denied (42501)", () => {
    const msg = humanizeDbError({ code: "42501", message: "permission denied" });
    expect(msg).toBe("You do not have permission to do that.");
  });

  it("maps Postgres not found (PGRST116)", () => {
    const msg = humanizeDbError({ code: "PGRST116", message: "no rows found" });
    expect(msg).toBe("Record not found.");
  });

  it("returns generic message for unknown errors", () => {
    const msg = humanizeDbError({ message: "Some random SQL error: SELECT * FROM secrets" });
    expect(msg).toBe("Something went wrong. Please try again.");
  });

  it("returns generic message for null error", () => {
    const msg = humanizeDbError(null);
    expect(msg).toBe("Something went wrong. Please try again.");
  });

  it("returns generic message for undefined error", () => {
    const msg = humanizeDbError(undefined as any);
    expect(msg).toBe("Something went wrong. Please try again.");
  });

  it("does not leak SQL in unknown error messages", () => {
    const msg = humanizeDbError({ message: "PostgrestException: SELECT password FROM users WHERE id=1" });
    expect(msg).toBe("Something went wrong. Please try again.");
    expect(msg).not.toContain("password");
    expect(msg).not.toContain("SELECT");
  });
});