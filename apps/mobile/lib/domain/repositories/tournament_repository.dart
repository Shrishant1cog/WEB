/// Domain repository interface for Phase 3 tournament operations.

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/tournament_models.dart';

abstract class TournamentRepository {
  Future<Either<Failure, List<TournamentListing>>> getPublicTournaments({
    String? query,
    String? status,
    String? mode,
  });

  Future<Either<Failure, TournamentListing>> getPublicTournament(String id);

  Future<Either<Failure, Tournament>> getTournament(String id);

  Future<Either<Failure, List<Tournament>>> getOrganizerTournaments(
      String userId);

  Future<Either<Failure, List<Tournament>>> getTournamentsByIds(
      List<String> ids);

  Future<Either<Failure, List<TournamentEntry>>> getMyEntries(String userId);

  Future<Either<Failure, List<TournamentEntry>>> getTournamentEntries(
      String tournamentId);

  Future<Either<Failure, RegistrationResult>> register(
    String tournamentId, {
    String? teamId,
  });

  Future<Either<Failure, String?>> withdraw(String entryId);

  Future<Either<Failure, String>> createTournament(TournamentInput input);

  Future<Either<Failure, void>> updateTournament(
    String tournamentId,
    TournamentInput input,
  );

  Future<Either<Failure, void>> setStatus(
    String tournamentId,
    String status, {
    String? reason,
  });

  Future<Either<Failure, String?>> promoteWaitlist(String tournamentId);
}
