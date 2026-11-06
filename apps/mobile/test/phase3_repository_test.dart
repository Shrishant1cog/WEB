import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fft_mobile/core/errors/failures.dart';
import 'package:fft_mobile/data/datasources/remote/team_remote_data_source.dart';
import 'package:fft_mobile/data/datasources/remote/tournament_remote_data_source.dart';
import 'package:fft_mobile/data/models/team_models.dart';
import 'package:fft_mobile/data/models/tournament_models.dart';
import 'package:fft_mobile/data/repositories/team_repository_impl.dart';
import 'package:fft_mobile/data/repositories/tournament_repository_impl.dart';

class _FakeTournamentRemote implements TournamentRemoteDataSource {
  int createCalls = 0;

  @override
  Future<Either<Failure, String>> createTournament(TournamentInput input) async {
    createCalls++;
    return const Right('created');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTeamRemote implements TeamRemoteDataSource {
  int createCalls = 0;

  @override
  Future<Either<Failure, String>> createTeam(TeamInput input) async {
    createCalls++;
    return const Right('team-id');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

TournamentInput _input({
  String title = 'Weekend Cup',
  int maxTeams = 16,
  String format = 'squad',
  int teamSize = 4,
  DateTime? registrationStarts,
  DateTime? registrationEnds,
  DateTime? tournamentStarts,
}) {
  return TournamentInput(
    title: title,
    format: format,
    mode: 'br',
    maxTeams: maxTeams,
    teamSize: teamSize,
    registrationStartsAt:
        registrationStarts ?? DateTime.utc(2026, 1, 1, 10),
    registrationEndsAt: registrationEnds ?? DateTime.utc(2026, 1, 2, 10),
    tournamentStartsAt: tournamentStarts ?? DateTime.utc(2026, 1, 3, 10),
  );
}

void main() {
  group('TournamentRepository validation', () {
    test('rejects short titles before calling the RPC', () async {
      final remote = _FakeTournamentRemote();
      final repository = TournamentRepositoryImpl(remote);

      final result = await repository.createTournament(_input(title: 'AB'));

      expect(result.isLeft(), isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(remote.createCalls, 0);
    });

    test('rejects invalid capacity', () async {
      final remote = _FakeTournamentRemote();
      final repository = TournamentRepositoryImpl(remote);

      final result = await repository.createTournament(_input(maxTeams: 0));

      expect(result.failure?.code, 'INVALID_CAPACITY');
      expect(remote.createCalls, 0);
    });

    test('rejects solo tournaments with a squad roster size', () async {
      final remote = _FakeTournamentRemote();
      final repository = TournamentRepositoryImpl(remote);

      final result = await repository.createTournament(
        _input(format: 'solo', teamSize: 4),
      );

      expect(result.failure?.code, 'SOLO_TEAM_SIZE');
      expect(remote.createCalls, 0);
    });

    test('rejects registration that closes after the tournament starts',
        () async {
      final remote = _FakeTournamentRemote();
      final repository = TournamentRepositoryImpl(remote);

      final result = await repository.createTournament(
        _input(
          registrationEnds: DateTime.utc(2026, 1, 4, 10),
          tournamentStarts: DateTime.utc(2026, 1, 3, 10),
        ),
      );

      expect(result.failure?.code, 'INVALID_TOURNAMENT_DATES');
      expect(remote.createCalls, 0);
    });

    test('delegates a valid tournament to the RPC', () async {
      final remote = _FakeTournamentRemote();
      final repository = TournamentRepositoryImpl(remote);

      final result = await repository.createTournament(_input());

      expect(result, const Right<Failure, String>('created'));
      expect(remote.createCalls, 1);
    });

    test('rejects unknown tournament statuses locally', () async {
      final repository = TournamentRepositoryImpl(_FakeTournamentRemote());

      final result = await repository.setStatus('t1', 'nonsense');

      expect(result.failure?.code, 'INVALID_STATUS');
    });
  });

  group('TeamRepository validation', () {
    test('rejects short team names', () async {
      final remote = _FakeTeamRemote();
      final repository = TeamRepositoryImpl(remote);

      final result = await repository.createTeam(const TeamInput(name: 'AB'));

      expect(result.failure?.code, 'INVALID_TEAM_NAME');
      expect(remote.createCalls, 0);
    });

    test('rejects out-of-range team tags', () async {
      final remote = _FakeTeamRemote();
      final repository = TeamRepositoryImpl(remote);

      final result = await repository.createTeam(
        const TeamInput(name: 'Alpha Squad', tag: 'TOOLONG'),
      );

      expect(result.failure?.code, 'INVALID_TEAM_TAG');
      expect(remote.createCalls, 0);
    });

    test('requires an invitation target', () async {
      final repository = TeamRepositoryImpl(_FakeTeamRemote());

      final result = await repository.inviteToTeam('team1');

      expect(result.failure?.code, 'INVITE_TARGET_REQUIRED');
    });

    test('rejects invitation expiry outside 1-168 hours', () async {
      final repository = TeamRepositoryImpl(_FakeTeamRemote());

      final result = await repository.inviteToTeam(
        'team1',
        email: 'player@example.com',
        expiresHours: 200,
      );

      expect(result.failure?.code, 'INVALID_INVITE_EXPIRY');
    });

    test('delegates a valid team to the RPC', () async {
      final remote = _FakeTeamRemote();
      final repository = TeamRepositoryImpl(remote);

      final result = await repository.createTeam(
        const TeamInput(name: 'Alpha Squad', tag: 'AL'),
      );

      expect(result, const Right<Failure, String>('team-id'));
      expect(remote.createCalls, 1);
    });
  });
}
