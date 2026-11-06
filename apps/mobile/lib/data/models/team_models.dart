/// Phase 3 team, roster and invitation models.

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

class Team {
  final String id;
  final String name;
  final String? tag;
  final String ownerId;
  final String? captainId;
  final String? description;
  final bool isPublic;
  final int maxMembers;
  final DateTime? createdAt;

  const Team({
    required this.id,
    required this.name,
    required this.tag,
    required this.ownerId,
    required this.captainId,
    required this.description,
    required this.isPublic,
    required this.maxMembers,
    required this.createdAt,
  });

  bool isCaptain(String userId) => captainId == userId || ownerId == userId;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: _text(json["id"]),
        name: _text(json["name"], "Team"),
        tag: json["tag"]?.toString(),
        ownerId: _text(json["owner_id"]),
        captainId: json["captain_id"]?.toString(),
        description: json["description"]?.toString(),
        isPublic: json["is_public"] != false,
        maxMembers: _int(json["max_members"], 10),
        createdAt: _date(json["created_at"]),
      );
}

class TeamMember {
  final String teamId;
  final String userId;
  final String role;
  final DateTime? joinedAt;
  final String? displayName;
  final String? inGameName;
  final String? inGameUid;

  const TeamMember({
    required this.teamId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.displayName,
    required this.inGameName,
    required this.inGameUid,
  });

  bool get isCaptain => role == "owner" || role == "captain";

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final profile = _object(json["profiles"]);
    return TeamMember(
      teamId: _text(json["team_id"]),
      userId: _text(json["user_id"]),
      role: _text(json["role"], "member"),
      joinedAt: _date(json["joined_at"]),
      displayName: profile["display_name"]?.toString(),
      inGameName: profile["in_game_name"]?.toString(),
      inGameUid: profile["in_game_uid"]?.toString(),
    );
  }
}

class TeamInvitation {
  final String id;
  final String teamId;
  final String? email;
  final String? invitedUserId;
  final String status;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const TeamInvitation({
    required this.id,
    required this.teamId,
    required this.email,
    required this.invitedUserId,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  String get target => email ?? invitedUserId ?? "player";

  factory TeamInvitation.fromJson(Map<String, dynamic> json) => TeamInvitation(
        id: _text(json["id"]),
        teamId: _text(json["team_id"]),
        email: json["email"]?.toString(),
        invitedUserId: json["invited_user_id"]?.toString(),
        status: _text(json["status"], "pending"),
        expiresAt: _date(json["expires_at"]),
        createdAt: _date(json["created_at"]),
      );
}

class TeamDetail {
  final Team team;
  final List<TeamMember> members;
  final List<TeamInvitation> invitations;
  final Map<String, int> memberCounts;

  const TeamDetail({
    required this.team,
    required this.members,
    required this.invitations,
    required this.memberCounts,
  });

  int get memberCount => members.length;
  bool isCaptain(String userId) => team.isCaptain(userId);
}

class TeamInput {
  final String name;
  final String? tag;
  final String? description;

  const TeamInput({required this.name, this.tag, this.description});
}
