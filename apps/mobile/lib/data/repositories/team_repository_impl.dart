/// Repository implementation with client-side validation.

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/remote/team_remote_data_source.dart';
import '../../data/models/team_models.dart';
import '../../domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource _remote;

  TeamRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Team>>> getMyTeams(String userId) =>
      _remote.getMyTeams(userId);

  @override
  Future<Either<Failure, TeamDetail>> getTeam(String teamId, String userId) =>
      _remote.getTeam(teamId, userId);

  @override
  Future<Either<Failure, Map<String, int>>> getMemberCounts(List<String> ids) =>
      _remote.getMemberCounts(ids);

  @override
  Future<Either<Failure, String>> createTeam(TeamInput input) {
    if (input.name.trim().length < 3 || input.name.trim().length > 50) {
      return Future.value(const Left(ValidationFailure(
        message: "Team name must be between 3 and 50 characters.",
        code: "INVALID_TEAM_NAME",
      )));
    }
    final tag = input.tag?.trim();
    if (tag != null && tag.isNotEmpty && (tag.length < 2 || tag.length > 6)) {
      return Future.value(const Left(ValidationFailure(
        message: "Team tag must be 2-6 characters.",
        code: "INVALID_TEAM_TAG",
      )));
    }
    return _remote.createTeam(input);
  }

  @override
  Future<Either<Failure, String>> inviteToTeam(
    String teamId, {
    String? email,
    String? invitedUserId,
    int expiresHours = 72,
  }) {
    if ((email == null || email.trim().isEmpty) && invitedUserId == null) {
      return Future.value(const Left(ValidationFailure(
        message: "Provide a player or an email address to invite.",
        code: "INVITE_TARGET_REQUIRED",
      )));
    }
    if (expiresHours < 1 || expiresHours > 168) {
      return Future.value(const Left(ValidationFailure(
        message: "Invitation expiry must be between 1 and 168 hours.",
        code: "INVALID_INVITE_EXPIRY",
      )));
    }
    return _remote.inviteToTeam(
      teamId,
      email: email,
      invitedUserId: invitedUserId,
      expiresHours: expiresHours,
    );
  }

  @override
  Future<Either<Failure, String>> acceptInvitation(String token) =>
      _remote.acceptInvitation(token);

  @override
  Future<Either<Failure, void>> declineInvitation(String token) =>
      _remote.declineInvitation(token);

  @override
  Future<Either<Failure, void>> revokeInvitation(String invitationId) =>
      _remote.revokeInvitation(invitationId);

  @override
  Future<Either<Failure, void>> removeMember(String teamId, String userId) {
    if (teamId.isEmpty || userId.isEmpty) {
      return Future.value(const Left(ValidationFailure(
        message: "Missing team member.",
        code: "INVALID_MEMBER",
      )));
    }
    return _remote.removeMember(teamId, userId);
  }

  @override
  Future<Either<Failure, void>> transferCaptaincy(
          String teamId, String newCaptain) =>
      _remote.transferCaptaincy(teamId, newCaptain);

  @override
  Future<Either<Failure, void>> leaveTeam(String teamId) =>
      _remote.leaveTeam(teamId);

  @override
  Future<Either<Failure, void>> dissolveTeam(String teamId) =>
      _remote.dissolveTeam(teamId);
}
