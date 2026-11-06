/// Repository implementation with client-side validation.

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/remote/tournament_remote_data_source.dart';
import '../../data/models/tournament_models.dart';
import '../../domain/repositories/tournament_repository.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource _remote;

  TournamentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<TournamentListing>>> getPublicTournaments({
    String? query,
    String? status,
    String? mode,
  }) =>
      _remote.getPublicTournaments(query: query, status: status, mode: mode);

  @override
  Future<Either<Failure, TournamentListing>> getPublicTournament(String id) =>
      _remote.getPublicTournament(id);

  @override
  Future<Either<Failure, Tournament>> getTournament(String id) =>
      _remote.getTournament(id);

  @override
  Future<Either<Failure, List<Tournament>>> getOrganizerTournaments(
          String userId) =>
      _remote.getOrganizerTournaments(userId);

  @override
  Future<Either<Failure, List<Tournament>>> getTournamentsByIds(
          List<String> ids) =>
      _remote.getTournamentsByIds(ids);

  @override
  Future<Either<Failure, List<TournamentEntry>>> getMyEntries(String userId) =>
      _remote.getMyEntries(userId);

  @override
  Future<Either<Failure, List<TournamentEntry>>> getTournamentEntries(
          String tournamentId) =>
      _remote.getTournamentEntries(tournamentId);

  @override
  Future<Either<Failure, RegistrationResult>> register(
    String tournamentId, {
    String? teamId,
  }) =>
      _remote.register(tournamentId, teamId: teamId);

  @override
  Future<Either<Failure, String?>> withdraw(String entryId) =>
      _remote.withdraw(entryId);

  @override
  Future<Either<Failure, String>> createTournament(
      TournamentInput input) async {
    final validation = _validate(input);
    if (validation != null) return Left(validation);
    return _remote.createTournament(input);
  }

  @override
  Future<Either<Failure, void>> updateTournament(
      String tournamentId, TournamentInput input) async {
    final validation = _validate(input);
    if (validation != null) return Left(validation);
    return _remote.updateTournament(tournamentId, input);
  }

  @override
  Future<Either<Failure, void>> setStatus(
    String tournamentId,
    String status, {
    String? reason,
  }) {
    const allowed = [
      "draft",
      "published",
      "registration_open",
      "registration_closed",
      "in_progress",
      "completed",
      "cancelled",
    ];
    if (!allowed.contains(status)) {
      return Future.value(const Left(ValidationFailure(
        message: "Invalid tournament status.",
        code: "INVALID_STATUS",
      )));
    }
    return _remote.setStatus(tournamentId, status, reason: reason);
  }

  @override
  Future<Either<Failure, String?>> promoteWaitlist(String tournamentId) =>
      _remote.promoteWaitlist(tournamentId);

  ValidationFailure? _validate(TournamentInput input) {
    if (input.title.trim().length < 3) {
      return const ValidationFailure(
        message: "Title must be at least 3 characters.",
        code: "TITLE_TOO_SHORT",
      );
    }
    if (input.maxTeams < 1 || input.maxTeams > 200) {
      return const ValidationFailure(
        message: "Capacity must be between 1 and 200 entries.",
        code: "INVALID_CAPACITY",
      );
    }
    if (!["1", "2", "4"].contains(input.teamSize.toString())) {
      return const ValidationFailure(
        message: "Roster size must be 1, 2 or 4.",
        code: "INVALID_TEAM_SIZE",
      );
    }
    if (input.format == "solo" && input.teamSize != 1) {
      return const ValidationFailure(
        message: "Solo tournaments require a roster size of 1.",
        code: "SOLO_TEAM_SIZE",
      );
    }
    if (input.format != "solo" && input.teamSize == 1) {
      return const ValidationFailure(
        message: "Team tournaments need a roster size above 1.",
        code: "TEAM_TEAM_SIZE",
      );
    }
    if (!input.registrationStartsAt.isBefore(input.registrationEndsAt)) {
      return const ValidationFailure(
        message: "Registration must end after it opens.",
        code: "INVALID_REGISTRATION_WINDOW",
      );
    }
    if (input.registrationEndsAt.isAfter(input.tournamentStartsAt)) {
      return const ValidationFailure(
        message: "Registration must close before the tournament starts.",
        code: "INVALID_TOURNAMENT_DATES",
      );
    }
    return null;
  }
}
