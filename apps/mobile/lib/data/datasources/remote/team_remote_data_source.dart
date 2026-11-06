/// Remote data source for Phase 3 team management.

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../models/team_models.dart';

abstract class TeamRemoteDataSource {
  Future<Either<Failure, List<Team>>> getMyTeams(String userId);

  Future<Either<Failure, TeamDetail>> getTeam(String teamId, String userId);

  Future<Either<Failure, Map<String, int>>> getMemberCounts(List<String> ids);

  Future<Either<Failure, String>> createTeam(TeamInput input);

  Future<Either<Failure, String>> inviteToTeam(
    String teamId, {
    String? email,
    String? invitedUserId,
    int expiresHours = 72,
  });

  Future<Either<Failure, String>> acceptInvitation(String token);

  Future<Either<Failure, void>> declineInvitation(String token);

  Future<Either<Failure, void>> revokeInvitation(String invitationId);

  Future<Either<Failure, void>> removeMember(String teamId, String userId);

  Future<Either<Failure, void>> transferCaptaincy(
      String teamId, String newCaptain);

  Future<Either<Failure, void>> leaveTeam(String teamId);

  Future<Either<Failure, void>> dissolveTeam(String teamId);
}

class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  final SupabaseClient _client;

  TeamRemoteDataSourceImpl(this._client);

  Failure _failure(Object error) => ServerFailure(
        message: humanizeError(error),
        originalError: error,
      );

  @override
  Future<Either<Failure, List<Team>>> getMyTeams(String userId) async {
    try {
      final membershipRows = await _client
          .from("team_members")
          .select("team_id")
          .eq("user_id", userId);
      final ids = (membershipRows as List)
          .map((row) => (row as Map)["team_id"] as String)
          .toList();
      if (ids.isEmpty) return const Right([]);

      final rows = await _client
          .from("teams")
          .select()
          .inFilter("id", ids)
          .filter("deleted_at", "is", null)
          .order("created_at", ascending: false);
      return Right((rows as List)
          .map((row) => Team.fromJson((row as Map).cast<String, dynamic>()))
          .toList());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, TeamDetail>> getTeam(
      String teamId, String userId) async {
    try {
      final teamRow = await _client
          .from("teams")
          .select()
          .eq("id", teamId)
          .filter("deleted_at", "is", null)
          .maybeSingle();
      if (teamRow == null) {
        return const Left(NotFoundFailure(message: "Team not found."));
      }

      final memberRows = await _client
          .from("team_members")
          .select("*, profiles(display_name, in_game_name, in_game_uid)")
          .eq("team_id", teamId)
          .order("joined_at", ascending: true);

      final invitationRows = await _client
          .from("team_invitations")
          .select()
          .eq("team_id", teamId)
          .eq("status", "pending")
          .order("created_at", ascending: false);

      final members = (memberRows as List)
          .map((row) => TeamMember.fromJson((row as Map).cast<String, dynamic>()))
          .toList();

      return Right(TeamDetail(
        team: Team.fromJson(teamRow),
        members: members,
        invitations: (invitationRows as List)
            .map((row) =>
                TeamInvitation.fromJson((row as Map).cast<String, dynamic>()))
            .toList(),
        memberCounts: {teamId: members.length},
      ));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getMemberCounts(
      List<String> ids) async {
    if (ids.isEmpty) return const Right({});
    try {
      final rows = await _client
          .from("team_members")
          .select("team_id")
          .inFilter("team_id", ids);
      final counts = <String, int>{for (final id in ids) id: 0};
      for (final row in rows as List) {
        final teamId = (row as Map)["team_id"] as String;
        counts[teamId] = (counts[teamId] ?? 0) + 1;
      }
      return Right(counts);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> createTeam(TeamInput input) async {
    try {
      final id = await _client.rpc("create_team", params: {
        "p_name": input.name,
        "p_tag": input.tag,
        "p_description": input.description,
      });
      return Right(id.toString());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> inviteToTeam(
    String teamId, {
    String? email,
    String? invitedUserId,
    int expiresHours = 72,
  }) async {
    try {
      final token = await _client.rpc("invite_to_team", params: {
        "p_team_id": teamId,
        "p_email": email,
        "p_invited_user_id": invitedUserId,
        "p_expires_hours": expiresHours,
      });
      return Right(token.toString());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> acceptInvitation(String token) async {
    try {
      final teamId =
          await _client.rpc("accept_team_invitation", params: {"p_token": token});
      return Right(teamId.toString());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> declineInvitation(String token) async {
    try {
      await _client
          .rpc("decline_team_invitation", params: {"p_token": token});
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> revokeInvitation(String invitationId) async {
    try {
      await _client.rpc("revoke_team_invitation",
          params: {"p_invitation_id": invitationId});
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(
      String teamId, String userId) async {
    try {
      await _client.rpc("remove_team_member",
          params: {"p_team_id": teamId, "p_user_id": userId});
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> transferCaptaincy(
      String teamId, String newCaptain) async {
    try {
      await _client.rpc("transfer_team_captaincy", params: {
        "p_team_id": teamId,
        "p_new_captain": newCaptain,
      });
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(String teamId) async {
    try {
      await _client.rpc("leave_team", params: {"p_team_id": teamId});
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> dissolveTeam(String teamId) async {
    try {
      await _client.rpc("dissolve_team", params: {"p_team_id": teamId});
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }
}
