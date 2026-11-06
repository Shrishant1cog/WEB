/// Domain repository interface for Phase 3 team management.

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/team_models.dart';

abstract class TeamRepository {
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
