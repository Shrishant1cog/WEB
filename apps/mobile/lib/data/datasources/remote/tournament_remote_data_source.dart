/// Remote data source for Phase 3 tournament operations.
///
/// All business rules (capacity, waitlist, eligibility, authorization) live in
/// PostgreSQL SECURITY DEFINER functions; this data source only calls them.

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../models/tournament_models.dart';

abstract class TournamentRemoteDataSource {
  Future<Either<Failure, List<TournamentListing>>> getPublicTournaments({
    String? query,
    String? status,
    String? mode,
  });

  Future<Either<Failure, TournamentListing>> getPublicTournament(String id);

  Future<Either<Failure, Tournament>> getTournament(String id);

  Future<Either<Failure, List<Tournament>>> getOrganizerTournaments(String userId);

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

class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final SupabaseClient _client;

  TournamentRemoteDataSourceImpl(this._client);

  String get _uid {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException("Not authenticated");
    return user.id;
  }

  Failure _failure(Object error) => ServerFailure(
        message: humanizeError(error),
        originalError: error,
      );

  @override
  Future<Either<Failure, List<TournamentListing>>> getPublicTournaments({
    String? query,
    String? status,
    String? mode,
  }) async {
    try {
      var request = _client.from("tournament_public_listing").select();
      if (query != null && query.trim().isNotEmpty) {
        request = request.ilike("title", "%${query.trim()}%");
      }
      if (status != null && status.isNotEmpty && status != "all") {
        request = request.eq("status", status);
      }
      if (mode != null && mode.isNotEmpty && mode != "all") {
        request = request.eq("mode", mode);
      }
      final rows = await request.order("tournament_starts_at", ascending: true);
      return Right(
        (rows as List)
            .map((row) => TournamentListing.fromJson(
                (row as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, TournamentListing>> getPublicTournament(
      String id) async {
    try {
      final row = await _client
          .from("tournament_public_listing")
          .select()
          .eq("id", id)
          .maybeSingle();
      if (row == null) {
        return const Left(NotFoundFailure(message: "Tournament not found."));
      }
      return Right(TournamentListing.fromJson(row));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Tournament>> getTournament(String id) async {
    try {
      final row =
          await _client.from("tournaments").select().eq("id", id).maybeSingle();
      if (row == null) {
        return const Left(NotFoundFailure(message: "Tournament not found."));
      }
      return Right(Tournament.fromJson(row));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, List<Tournament>>> getOrganizerTournaments(
      String userId) async {
    try {
      final membershipRows = await _client
          .from("tournament_organizers")
          .select("tournament_id")
          .eq("user_id", userId);
      final ids = (membershipRows as List)
          .map((row) => (row as Map)["tournament_id"] as String)
          .toList();
      if (ids.isEmpty) return const Right([]);

      final rows = await _client
          .from("tournaments")
          .select()
          .inFilter("id", ids)
          .filter("deleted_at", "is", null)
          .order("created_at", ascending: false);
      return Right((rows as List)
          .map((row) =>
              Tournament.fromJson((row as Map).cast<String, dynamic>()))
          .toList());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, List<Tournament>>> getTournamentsByIds(
      List<String> ids) async {
    if (ids.isEmpty) return const Right([]);
    try {
      final rows =
          await _client.from("tournaments").select().inFilter("id", ids);
      return Right((rows as List)
          .map((row) =>
              Tournament.fromJson((row as Map).cast<String, dynamic>()))
          .toList());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  Future<List<TournamentEntry>> _entriesFromRows(List<dynamic> rows) async {
    final entries = <TournamentEntry>[];
    for (final row in rows) {
      final json = (row as Map).cast<String, dynamic>();
      final memberRows = json["tournament_entry_members"];
      final members = memberRows is List
          ? memberRows
              .map((member) => TournamentEntryMember.fromJson(
                  (member as Map).cast<String, dynamic>()))
              .toList()
          : <TournamentEntryMember>[];
      entries.add(TournamentEntry(
        registration: TournamentRegistration.fromJson(json),
        members: members,
      ));
    }
    return entries;
  }

  @override
  Future<Either<Failure, List<TournamentEntry>>> getMyEntries(
      String userId) async {
    try {
      final rows = await _client
          .from("tournament_registrations")
          .select("*, tournament_entry_members(*)")
          .eq("user_id", userId)
          .order("registered_at", ascending: false);
      return Right(await _entriesFromRows(rows as List));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, List<TournamentEntry>>> getTournamentEntries(
      String tournamentId) async {
    try {
      final rows = await _client
          .from("tournament_registrations")
          .select("*, tournament_entry_members(*)")
          .eq("tournament_id", tournamentId)
          .order("status", ascending: true)
          .order("waitlist_seq", ascending: true, nullsFirst: false)
          .order("registered_at", ascending: true);
      return Right(await _entriesFromRows(rows as List));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, RegistrationResult>> register(
    String tournamentId, {
    String? teamId,
  }) async {
    try {
      final data = await _client.rpc(
        "register_tournament_entry",
        params: {
          "p_tournament_id": tournamentId,
          "p_team_id": teamId,
        },
      );
      return Right(RegistrationResult.fromJson(
          (data as Map).cast<String, dynamic>()));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String?>> withdraw(String entryId) async {
    try {
      final data = await _client.rpc(
        "withdraw_tournament_entry",
        params: {"p_entry_id": entryId},
      );
      final promoted = data is Map ? data["promoted_entry_id"]?.toString() : null;
      return Right(promoted);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> createTournament(TournamentInput input) async {
    try {
      final id = await _client.rpc(
        "create_tournament",
        params: {"p_payload": input.toPayload()},
      );
      return Right(id.toString());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> updateTournament(
    String tournamentId,
    TournamentInput input,
  ) async {
    try {
      await _client.rpc(
        "update_tournament",
        params: {
          "p_tournament_id": tournamentId,
          "p_payload": input.toPayload(),
        },
      );
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, void>> setStatus(
    String tournamentId,
    String status, {
    String? reason,
  }) async {
    try {
      await _client.rpc(
        "set_tournament_status",
        params: {
          "p_tournament_id": tournamentId,
          "p_status": status,
          "p_reason": reason,
        },
      );
      return const Right(null);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String?>> promoteWaitlist(String tournamentId) async {
    try {
      final data = await _client.rpc(
        "organizer_promote_waitlist",
        params: {"p_tournament_id": tournamentId},
      );
      return Right(data?.toString());
    } catch (error) {
      return Left(_failure(error));
    }
  }
}
