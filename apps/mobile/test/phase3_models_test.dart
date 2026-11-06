import 'package:flutter_test/flutter_test.dart';
import 'package:fft_mobile/core/errors/error_mapper.dart';
import 'package:fft_mobile/data/models/team_models.dart';
import 'package:fft_mobile/data/models/tournament_models.dart';

void main() {
  group('Tournament parsing', () {
    test('parses a tournament listing and derives capacity flags', () {
      final listing = TournamentListing.fromJson({
        'id': 't1',
        'title': 'Weekend Cup',
        'format': 'squad',
        'mode': 'br',
        'max_teams': 16,
        'team_size': 4,
        'registration_starts_at': '2026-01-01T10:00:00Z',
        'registration_ends_at': '2026-01-02T10:00:00Z',
        'tournament_starts_at': '2026-01-03T10:00:00Z',
        'status': 'registration_open',
        'visibility': 'public',
        'eligibility': {'requires_ingame_id': true},
        'waitlist_enabled': true,
        'organizer_name': 'Organizer',
        'confirmed_entries': 16,
        'waitlisted_entries': 2,
      });

      expect(listing.id, 't1');
      expect(listing.requiresTeam, isTrue);
      expect(listing.requiresInGameId, isTrue);
      expect(listing.isFull, isTrue);
      expect(listing.confirmedEntries, 16);
      expect(listing.registrationStartsAt.toUtc().hour, 10);
    });

    test('solo tournaments do not require a team', () {
      final tournament = Tournament.fromJson({
        'id': 't2',
        'organizer_id': 'u1',
        'title': 'Solo Showdown',
        'format': 'solo',
        'mode': 'br',
        'max_teams': 48,
        'team_size': 1,
        'registration_starts_at': '2026-01-01T10:00:00Z',
        'registration_ends_at': '2026-01-02T10:00:00Z',
        'tournament_starts_at': '2026-01-03T10:00:00Z',
      });

      expect(tournament.requiresTeam, isFalse);
      expect(tournament.teamSize, 1);
      expect(tournament.status, 'draft');
    });

    test('payload serializes timestamps as UTC ISO-8601 strings', () {
      final input = TournamentInput(
        title: 'Cup',
        format: 'squad',
        mode: 'br',
        maxTeams: 8,
        teamSize: 4,
        registrationStartsAt: DateTime.utc(2026, 1, 1, 10),
        registrationEndsAt: DateTime.utc(2026, 1, 2, 10),
        tournamentStartsAt: DateTime.utc(2026, 1, 3, 10),
      );

      final payload = input.toPayload();
      expect(payload['registration_starts_at'], '2026-01-01T10:00:00.000Z');
      expect(payload['team_size'], 4);
      expect(payload['eligibility'], {'requires_ingame_id': false});
    });

    test('registration result exposes waitlist state and position', () {
      final result = RegistrationResult.fromJson({
        'entry_id': 'e1',
        'status': 'waitlisted',
        'waitlist_position': 3,
      });
      expect(result.isWaitlisted, isTrue);
      expect(result.waitlistPosition, 3);
    });
  });

  group('Team parsing', () {
    test('captain and owner both have captain rights', () {
      const team = Team(
        id: 'team1',
        name: 'Alpha',
        tag: 'AL',
        ownerId: 'owner',
        captainId: 'captain',
        description: null,
        isPublic: true,
        maxMembers: 4,
        createdAt: null,
      );

      expect(team.isCaptain('owner'), isTrue);
      expect(team.isCaptain('captain'), isTrue);
      expect(team.isCaptain('member'), isFalse);
    });

    test('team members parse nested profile fields', () {
      final member = TeamMember.fromJson({
        'team_id': 'team1',
        'user_id': 'u1',
        'role': 'captain',
        'profiles': {
          'display_name': 'Player One',
          'in_game_name': 'FFPlayer',
          'in_game_uid': '123456',
        },
      });

      expect(member.isCaptain, isTrue);
      expect(member.displayName, 'Player One');
      expect(member.inGameUid, '123456');
    });
  });

  group('Error mapping', () {
    test('maps known RPC rule keys to friendly messages', () {
      final message = humanizeError(
        'PostgrestException(message: TOURNAMENT_FULL: capacity reached)',
      );
      expect(message, contains('full'));
    });

    test('maps unknown errors without leaking SQL text', () {
      final message = humanizeError('PostgrestException(message: boom)');
      expect(message, 'Something went wrong. Please try again.');
    });
  });
}
