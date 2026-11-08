/**
 * Maps database exception codes/messages (raised by SECURITY DEFINER RPCs)
 * to user-facing messages. Keeps clients from leaking SQL detail while still
 * surfacing actionable validation feedback.
 */
const MESSAGES: Record<string, string> = {
  AUTH_REQUIRED: "Please sign in to continue.",
  NOT_TOURNAMENT_ORGANIZER: "You do not have permission to manage this tournament.",
  TOURNAMENT_NOT_FOUND: "Tournament not found.",
  TOURNAMENT_NOT_EDITABLE: "This tournament can no longer be edited.",
  INVALID_STATUS_TRANSITION: "That status change is not allowed from the current state.",
  INVALID_TOURNAMENT_DATES: "Registration must end before the tournament starts.",
  REGISTRATION_NOT_OPEN: "Registration is not open for this tournament.",
  REGISTRATION_WINDOW_CLOSED: "Registration is outside the configured window.",
  ORGANIZER_CANNOT_PARTICIPATE: "Organizers cannot enter their own tournament.",
  TEAM_REQUIRED_FOR_SQUAD: "Squad tournaments require a complete team.",
  TEAM_NOT_ALLOWED_FOR_SOLO: "Solo tournaments do not accept teams.",
  TEAM_NOT_FOUND: "Team not found.",
  ONLY_CAPTAIN_CAN_REGISTER: "Only the team captain can register the team.",
  ROSTER_INCOMPLETE: "Your roster is not complete for this tournament.",
  ELIGIBILITY_INGAME_ID_REQUIRED: "Every member must add a Free Fire in-game UID before registering.",
  PLAYER_ACCOUNT_DELETED: "One of the selected players has a deleted account.",
  PLAYER_ALREADY_REGISTERED: "One of the selected players is already registered in this tournament.",
  ALREADY_REGISTERED: "You are already registered in this tournament.",
  ENTRY_TYPE_CONFLICT: "You already have an entry of a different type in this tournament.",
  TOURNAMENT_FULL: "This tournament is full and the waitlist is disabled.",
  WITHDRAWAL_CLOSED: "Withdrawals are closed because registration has ended.",
  WITHDRAWAL_DEADLINE_PASSED: "The withdrawal deadline has passed.",
  ENTRY_NOT_FOUND: "Registration not found.",
  NOT_ENTRY_OWNER: "You can only withdraw your own registration.",
  INVALID_TEAM_NAME: "Team name must be between 3 and 50 characters.",
  ONLY_CAPTAIN_CAN_INVITE: "Only the team captain can invite players.",
  ONLY_CAPTAIN_CAN_REMOVE: "Only the team captain can remove members.",
  ONLY_CAPTAIN_CAN_TRANSFER: "Only the team captain can transfer captaincy.",
  ONLY_CAPTAIN_CAN_DISSOLVE: "Only the team captain can dissolve the team.",
  ONLY_CAPTAIN_CAN_REVOKE: "Only the team captain can revoke invitations.",
  INVITE_TARGET_REQUIRED: "Provide a player or an email address to invite.",
  INVALID_INVITE_EXPIRY: "Invitation expiry must be between 1 and 168 hours.",
  INVITE_RATE_LIMIT: "Too many invitations for this team. Try again later.",
  TEAM_FULL: "This team is full.",
  ALREADY_TEAM_MEMBER: "That player is already on the team.",
  INVALID_INVITATION: "This invitation is invalid or has already been used.",
  INVITATION_EXPIRED: "This invitation has expired.",
  INVITATION_FOR_ANOTHER_USER: "This invitation was issued to a different player.",
  INVITATION_NOT_FOUND: "Invitation not found.",
  MEMBER_NOT_FOUND: "Team member not found.",
  NOT_TEAM_MEMBER: "You are not a member of this team.",
  NEW_CAPTAIN_MUST_BE_MEMBER: "The new captain must already be on the team.",
  USE_LEAVE_TEAM: "Use 'Leave team' to remove yourself.",
  TRANSFER_CAPTAINCY_REQUIRED: "Transfer captaincy before leaving the team.",
  TEAM_HAS_ACTIVE_REGISTRATION: "Dissolve is blocked while the team has an active registration.",
  NOT_PLATFORM_ADMIN: "You do not have platform administrator access.",
  INSUFFICIENT_ADMIN_ROLE: "Your administrator role is not permitted to do that.",
  ACCOUNT_INACTIVE: "This account is suspended.",
  ORGANIZER_NOT_APPROVED: "Your organizer account must be approved before you can create tournaments.",
  INVALID_REPORT_CATEGORY: "Choose a valid report category.",
  INVALID_REPORT_SUBJECT: "Choose a valid report subject.",
  INVALID_REPORT_DESCRIPTION: "Describe the issue in 10 to 4000 characters.",
  TOO_MANY_EVIDENCE_FILES: "Attach at most 10 evidence files.",
  ABUSE_REPORTING_DISABLED: "Abuse reporting is currently disabled.",
  REPORT_NOT_FOUND: "Report not found.",
  INVALID_REPORT_STATUS: "That report status is not valid.",
  INVALID_REPORT_SEVERITY: "That severity is not valid.",
  INVALID_RESOLUTION: "Provide a resolution of at least 5 characters.",
  CANNOT_SUSPEND_SELF: "You cannot suspend your own account.",
  CANNOT_SUSPEND_SUPER_ADMIN: "Super administrators cannot be suspended.",
  SUSPENSION_REASON_REQUIRED: "Provide a suspension reason.",
  USER_NOT_FOUND: "User not found.",
  INVALID_ORGANIZER_STATUS: "That organizer status is not valid.",
  MODERATOR_PARTICIPATES_IN_TOURNAMENT: "A participant cannot moderate their own tournament.",
  CANNOT_DEMOTE_OWNER: "The tournament owner cannot be demoted to moderator.",
  ADMIN_NOT_FOUND: "Administrator not found.",
  CANNOT_REVOKE_SELF: "You cannot revoke your own administrator access.",
  INVALID_ADMIN_ROLE: "That administrator role is not valid.",
  INVALID_SETTING_KEY: "That setting key is not valid.",
  INVALID_SETTING_VALUE: "That setting value is not valid.",
  INVALID_NOTIFICATION_CATEGORY: "That notification category is not valid.",
  INVALID_DEVICE_TOKEN: "That device token is not valid.",
  INVALID_DEVICE_PLATFORM: "That device platform is not supported.",
  ORGANIZER_CANNOT_MODERATE_OWN: "Organizers cannot moderate their own tournament.",
};

export function humanizeDbError(error: { message?: string; code?: string } | null): string {
  if (!error) return "Something went wrong. Please try again.";
  const raw = error.message ?? "";

  const key = Object.keys(MESSAGES).find((candidate) => raw.startsWith(candidate));
  if (key) {
    const message = MESSAGES[key];
    const detail = raw.slice(key.length).replace(/^:\s*/, "");
    return detail ? `${message} (${detail})` : message;
  }

  if (error.code === "23505") return "That record already exists.";
  if (error.code === "42501") return "You do not have permission to do that.";
  if (error.code === "PGRST116") return "Record not found.";

  return "Something went wrong. Please try again.";
}
