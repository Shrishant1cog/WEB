/// Phase 3 tournament domain models.
///
/// Plain classes (no code generation) so the mobile app stays compatible with
/// the pinned analyzer/Freezed versions.

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

Map<String, dynamic> _object(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return const <String, dynamic>{};
}

int _int(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? fallback;
}

String _text(Object? value, [String fallback = ""]) =>
    value?.toString() ?? fallback;

class Tournament {
  final String id;
  final String organizerId;
  final String title;
  final String? description;
  final String format;
  final String mode;
  final String? map;
  final int maxTeams;
  final int teamSize;
  final DateTime registrationStartsAt;
  final DateTime registrationEndsAt;
  final DateTime tournamentStartsAt;
  final DateTime? tournamentEndsAt;
  final String? prizePool;
  final String? rulesUrl;
  final String? rulesText;
  final String? contactInfo;
  final String status;
  final String visibility;
  final Map<String, dynamic> eligibility;
  final bool waitlistEnabled;
  final DateTime? withdrawalDeadline;
  final DateTime? createdAt;

  const Tournament({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.format,
    required this.mode,
    required this.map,
    required this.maxTeams,
    required this.teamSize,
    required this.registrationStartsAt,
    required this.registrationEndsAt,
    required this.tournamentStartsAt,
    required this.tournamentEndsAt,
    required this.prizePool,
    required this.rulesUrl,
    required this.rulesText,
    required this.contactInfo,
    required this.status,
    required this.visibility,
    required this.eligibility,
    required this.waitlistEnabled,
    required this.withdrawalDeadline,
    required this.createdAt,
  });

  bool get requiresTeam => format != "solo";
  bool get requiresInGameId =>
      eligibility["requires_ingame_id"] == true;

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
        id: _text(json["id"]),
        organizerId: _text(json["organizer_id"]),
        title: _text(json["title"], "Tournament"),
        description: json["description"]?.toString(),
        format: _text(json["format"], "squad"),
        mode: _text(json["mode"], "br"),
        map: json["map"]?.toString(),
        maxTeams: _int(json["max_teams"], 1),
        teamSize: _int(json["team_size"], 1),
        registrationStartsAt:
            _date(json["registration_starts_at"]) ?? DateTime.now(),
        registrationEndsAt:
            _date(json["registration_ends_at"]) ?? DateTime.now(),
        tournamentStartsAt:
            _date(json["tournament_starts_at"]) ?? DateTime.now(),
        tournamentEndsAt: _date(json["tournament_ends_at"]),
        prizePool: json["prize_pool"]?.toString(),
        rulesUrl: json["rules_url"]?.toString(),
        rulesText: json["rules_text"]?.toString(),
        contactInfo: json["contact_info"]?.toString(),
        status: _text(json["status"], "draft"),
        visibility: _text(json["visibility"], "public"),
        eligibility: _object(json["eligibility"]),
        waitlistEnabled: json["waitlist_enabled"] != false,
        withdrawalDeadline: _date(json["withdrawal_deadline"]),
        createdAt: _date(json["created_at"]),
      );
}

/// Aggregate read model from the `tournament_public_listing` view.
class TournamentListing {
  final String id;
  final String title;
  final String? description;
  final String format;
  final String mode;
  final String? map;
  final int maxTeams;
  final int teamSize;
  final DateTime registrationStartsAt;
  final DateTime registrationEndsAt;
  final DateTime tournamentStartsAt;
  final DateTime? tournamentEndsAt;
  final String? prizePool;
  final String? rulesUrl;
  final String? rulesText;
  final String? contactInfo;
  final String status;
  final String visibility;
  final Map<String, dynamic> eligibility;
  final bool waitlistEnabled;
  final DateTime? withdrawalDeadline;
  final DateTime? publishedAt;
  final String organizerName;
  final int confirmedEntries;
  final int waitlistedEntries;

  const TournamentListing({
    required this.id,
    required this.title,
    required this.description,
    required this.format,
    required this.mode,
    required this.map,
    required this.maxTeams,
    required this.teamSize,
    required this.registrationStartsAt,
    required this.registrationEndsAt,
    required this.tournamentStartsAt,
    required this.tournamentEndsAt,
    required this.prizePool,
    required this.rulesUrl,
    required this.rulesText,
    required this.contactInfo,
    required this.status,
    required this.visibility,
    required this.eligibility,
    required this.waitlistEnabled,
    required this.withdrawalDeadline,
    required this.publishedAt,
    required this.organizerName,
    required this.confirmedEntries,
    required this.waitlistedEntries,
  });

  bool get requiresTeam => format != "solo";
  bool get requiresInGameId => eligibility["requires_ingame_id"] == true;
  bool get isFull => confirmedEntries >= maxTeams;

  factory TournamentListing.fromJson(Map<String, dynamic> json) =>
      TournamentListing(
        id: _text(json["id"]),
        title: _text(json["title"], "Tournament"),
        description: json["description"]?.toString(),
        format: _text(json["format"], "squad"),
        mode: _text(json["mode"], "br"),
        map: json["map"]?.toString(),
        maxTeams: _int(json["max_teams"], 1),
        teamSize: _int(json["team_size"], 1),
        registrationStartsAt:
            _date(json["registration_starts_at"]) ?? DateTime.now(),
        registrationEndsAt:
            _date(json["registration_ends_at"]) ?? DateTime.now(),
        tournamentStartsAt:
            _date(json["tournament_starts_at"]) ?? DateTime.now(),
        tournamentEndsAt: _date(json["tournament_ends_at"]),
        prizePool: json["prize_pool"]?.toString(),
        rulesUrl: json["rules_url"]?.toString(),
        rulesText: json["rules_text"]?.toString(),
        contactInfo: json["contact_info"]?.toString(),
        status: _text(json["status"], "published"),
        visibility: _text(json["visibility"], "public"),
        eligibility: _object(json["eligibility"]),
        waitlistEnabled: json["waitlist_enabled"] != false,
        withdrawalDeadline: _date(json["withdrawal_deadline"]),
        publishedAt: _date(json["published_at"]),
        organizerName: _text(json["organizer_name"], "Organizer"),
        confirmedEntries: _int(json["confirmed_entries"]),
        waitlistedEntries: _int(json["waitlisted_entries"]),
      );
}

class TournamentRegistration {
  final String id;
  final String tournamentId;
  final String userId;
  final String? teamId;
  final String? entryType;
  final String? teamName;
  final String status;
  final int? waitlistSeq;
  final DateTime? registeredAt;
  final DateTime? waitlistedAt;
  final DateTime? withdrawnAt;
  final String? cancellationReason;

  const TournamentRegistration({
    required this.id,
    required this.tournamentId,
    required this.userId,
    required this.teamId,
    required this.entryType,
    required this.teamName,
    required this.status,
    required this.waitlistSeq,
    required this.registeredAt,
    required this.waitlistedAt,
    required this.withdrawnAt,
    required this.cancellationReason,
  });

  bool get isActive => status == "confirmed" || status == "waitlisted";
  bool get isConfirmed => status == "confirmed";
  bool get isWaitlisted => status == "waitlisted";

  factory TournamentRegistration.fromJson(Map<String, dynamic> json) =>
      TournamentRegistration(
        id: _text(json["id"]),
        tournamentId: _text(json["tournament_id"]),
        userId: _text(json["user_id"]),
        teamId: json["team_id"]?.toString(),
        entryType: json["entry_type"]?.toString(),
        teamName: json["team_name"]?.toString(),
        status: _text(json["status"], "pending"),
        waitlistSeq: json["waitlist_seq"] == null
            ? null
            : _int(json["waitlist_seq"]),
        registeredAt: _date(json["registered_at"]),
        waitlistedAt: _date(json["waitlisted_at"]),
        withdrawnAt: _date(json["withdrawn_at"]),
        cancellationReason: json["cancellation_reason"]?.toString(),
      );
}

class TournamentEntryMember {
  final String entryId;
  final String userId;
  final String role;
  final String? displayName;
  final String? inGameName;
  final String? inGameUid;

  const TournamentEntryMember({
    required this.entryId,
    required this.userId,
    required this.role,
    required this.displayName,
    required this.inGameName,
    required this.inGameUid,
  });

  factory TournamentEntryMember.fromJson(Map<String, dynamic> json) {
    final profile = _object(json["profiles"]);
    return TournamentEntryMember(
      entryId: _text(json["entry_id"]),
      userId: _text(json["user_id"]),
      role: _text(json["role"], "member"),
      displayName: profile["display_name"]?.toString(),
      inGameName: json["in_game_name"]?.toString() ??
          profile["in_game_name"]?.toString(),
      inGameUid:
          json["in_game_uid"]?.toString() ?? profile["in_game_uid"]?.toString(),
    );
  }
}

class TournamentEntry {
  final TournamentRegistration registration;
  final List<TournamentEntryMember> members;

  const TournamentEntry({required this.registration, required this.members});

  String get label =>
      registration.teamName ??
      (members.isNotEmpty ? members.first.displayName ?? "Entry" : "Entry");
}

/// Input used by the create/update tournament RPCs.
class TournamentInput {
  final String title;
  final String? description;
  final String format;
  final String mode;
  final String? map;
  final int maxTeams;
  final int teamSize;
  final DateTime registrationStartsAt;
  final DateTime registrationEndsAt;
  final DateTime tournamentStartsAt;
  final DateTime? tournamentEndsAt;
  final DateTime? withdrawalDeadline;
  final String? prizePool;
  final String? rulesUrl;
  final String? rulesText;
  final String? contactInfo;
  final String visibility;
  final bool waitlistEnabled;
  final bool requiresInGameId;

  const TournamentInput({
    required this.title,
    required this.format,
    required this.mode,
    required this.maxTeams,
    required this.teamSize,
    required this.registrationStartsAt,
    required this.registrationEndsAt,
    required this.tournamentStartsAt,
    this.description,
    this.map,
    this.tournamentEndsAt,
    this.withdrawalDeadline,
    this.prizePool,
    this.rulesUrl,
    this.rulesText,
    this.contactInfo,
    this.visibility = "public",
    this.waitlistEnabled = true,
    this.requiresInGameId = false,
  });

  Map<String, dynamic> toPayload() => {
        "title": title,
        "description": description ?? "",
        "format": format,
        "mode": mode,
        "map": map ?? "",
        "max_teams": maxTeams,
        "team_size": format == "solo" ? 1 : teamSize,
        "registration_starts_at": registrationStartsAt.toUtc().toIso8601String(),
        "registration_ends_at": registrationEndsAt.toUtc().toIso8601String(),
        "tournament_starts_at": tournamentStartsAt.toUtc().toIso8601String(),
        "tournament_ends_at":
            tournamentEndsAt?.toUtc().toIso8601String() ?? "",
        "withdrawal_deadline":
            withdrawalDeadline?.toUtc().toIso8601String() ?? "",
        "prize_pool": prizePool ?? "",
        "rules_url": rulesUrl ?? "",
        "rules_text": rulesText ?? "",
        "contact_info": contactInfo ?? "",
        "visibility": visibility,
        "waitlist_enabled": waitlistEnabled,
        "eligibility": {"requires_ingame_id": requiresInGameId},
      };
}

/// Result of a registration attempt.
class RegistrationResult {
  final String entryId;
  final String status;
  final int? waitlistPosition;

  const RegistrationResult({
    required this.entryId,
    required this.status,
    required this.waitlistPosition,
  });

  bool get isWaitlisted => status == "waitlisted";

  factory RegistrationResult.fromJson(Map<String, dynamic> json) =>
      RegistrationResult(
        entryId: _text(json["entry_id"]),
        status: _text(json["status"], "confirmed"),
        waitlistPosition: json["waitlist_position"] == null
            ? null
            : _int(json["waitlist_position"]),
      );
}
