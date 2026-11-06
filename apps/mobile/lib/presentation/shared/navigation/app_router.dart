/// FFT Mobile App Router Configuration
/// Uses GoRouter for declarative routing with auth guards

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Feature imports (will be created in Phase 2+)
// import 'package:fft_mobile/presentation/features/auth/presentation/pages/login_page.dart';
// import 'package:fft_mobile/presentation/features/auth/presentation/pages/register_page.dart';
// import 'package:fft_mobile/presentation/features/auth/presentation/pages/password_reset_page.dart';
// import 'package:fft_mobile/presentation/features/tournaments/presentation/pages/tournament_list_page.dart';
// import 'package:fft_mobile/presentation/features/tournaments/presentation/pages/tournament_detail_page.dart';
// import 'package:fft_mobile/presentation/features/profile/presentation/pages/profile_page.dart';
// import 'package:fft_mobile/presentation/features/teams/presentation/pages/team_list_page.dart';
// import 'package:fft_mobile/presentation/features/teams/presentation/pages/team_detail_page.dart';
// import 'package:fft_mobile/presentation/features/matches/presentation/pages/match_list_page.dart';
// import 'package:fft_mobile/presentation/features/matches/presentation/pages/match_detail_page.dart';
// import 'package:fft_mobile/presentation/features/results/presentation/pages/results_page.dart';
// import 'package:fft_mobile/presentation/features/notifications/presentation/pages/notification_page.dart';
// import 'package:fft_mobile/presentation/shared/widgets/scaffold_with_nav_bar.dart';

/// Route names
class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordReset = '/password-reset';
  static const String passwordResetConfirm = '/password-reset/confirm';
  static const String emailVerify = '/email-verify';
  static const String authCallback = '/auth/callback';

  // Public (no auth required)
  static const String home = '/';
  static const String tournaments = '/tournaments';
  static const String tournamentDetail = '/tournaments/:tournamentId';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String support = '/support';
  static const String accountDeletion = '/account-deletion';

  // Protected (auth required)
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String myTournaments = '/my-tournaments';
  static const String myTeams = '/my-teams';
  static const String teamDetail = '/teams/:teamId';
  static const String createTeam = '/teams/create';
  static const String teamInvite = '/team/invite/:token';
  static const String matches = '/matches';
  static const String matchDetail = '/matches/:matchId';
  static const String results = '/results';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Organizer (organizer role required)
  static const String organizerDashboard = '/organizer';
  static const String organizerTournaments = '/organizer/tournaments';
  static const String organizerCreateTournament = '/organizer/tournaments/create';
  static const String organizerTournamentDetail = '/organizer/tournaments/:tournamentId';
  static const String organizerMatches = '/organizer/tournaments/:tournamentId/matches';
  static const String organizerMatchDetail = '/organizer/matches/:matchId';
  static const String organizerResults = '/organizer/tournaments/:tournamentId/results';
  static const String organizerAnnouncements = '/organizer/tournaments/:tournamentId/announcements';
  static const String organizerOrganization = '/organizer/organization';

  // Admin (admin role required)
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminOrganizers = '/admin/organizers';
  static const String adminTournaments = '/admin/tournaments';
  static const String adminModerators = '/admin/moderators';
  static const String adminAbuse = '/admin/abuse';
  static const String adminAudit = '/admin/audit';
  static const String adminSettings = '/admin/settings';
}

/// Route configuration
class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Public routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const _HomePage(),
      ),
      GoRoute(
        path: AppRoutes.tournaments,
        name: 'tournaments',
        builder: (context, state) => const _TournamentListPage(),
      ),
      GoRoute(
        path: AppRoutes.tournamentDetail,
        name: 'tournamentDetail',
        builder: (context, state) {
          final tournamentId = state.pathParameters['tournamentId']!;
          return _TournamentDetailPage(tournamentId: tournamentId);
        },
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const _StaticPage(title: 'Privacy Policy', assetPath: 'assets/legal/privacy.md'),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (context, state) => const _StaticPage(title: 'Terms of Service', assetPath: 'assets/legal/terms.md'),
      ),
      GoRoute(
        path: AppRoutes.support,
        name: 'support',
        builder: (context, state) => const _SupportPage(),
      ),
      GoRoute(
        path: AppRoutes.accountDeletion,
        name: 'accountDeletion',
        builder: (context, state) => const _AccountDeletionPage(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const _LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const _RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.passwordReset,
        name: 'passwordReset',
        builder: (context, state) => const _PasswordResetRequestPage(),
      ),
      GoRoute(
        path: AppRoutes.passwordResetConfirm,
        name: 'passwordResetConfirm',
        builder: (context, state) => const _PasswordResetConfirmPage(),
      ),
      GoRoute(
        path: AppRoutes.emailVerify,
        name: 'emailVerify',
        builder: (context, state) => const _EmailVerifyPage(),
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        name: 'authCallback',
        builder: (context, state) => const _AuthCallbackPage(),
      ),

      // Protected routes (require authentication)
      ShellRoute(
        builder: (context, state, child) => _AuthenticatedShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const _ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.profileEdit,
            name: 'profileEdit',
            builder: (context, state) => const _ProfileEditPage(),
          ),
          GoRoute(
            path: AppRoutes.myTournaments,
            name: 'myTournaments',
            builder: (context, state) => const _MyTournamentsPage(),
          ),
          GoRoute(
            path: AppRoutes.myTeams,
            name: 'myTeams',
            builder: (context, state) => const _MyTeamsPage(),
          ),
          GoRoute(
            path: AppRoutes.teamDetail,
            name: 'teamDetail',
            builder: (context, state) {
              final teamId = state.pathParameters['teamId']!;
              return _TeamDetailPage(teamId: teamId);
            },
          ),
          GoRoute(
            path: AppRoutes.createTeam,
            name: 'createTeam',
            builder: (context, state) => const _CreateTeamPage(),
          ),
          GoRoute(
            path: AppRoutes.teamInvite,
            name: 'teamInvite',
            builder: (context, state) {
              final token = state.pathParameters['token']!;
              return _TeamInvitePage(token: token);
            },
          ),
          GoRoute(
            path: AppRoutes.matches,
            name: 'matches',
            builder: (context, state) => const _MatchesPage(),
          ),
          GoRoute(
            path: AppRoutes.matchDetail,
            name: 'matchDetail',
            builder: (context, state) {
              final matchId = state.pathParameters['matchId']!;
              return _MatchDetailPage(matchId: matchId);
            },
          ),
          GoRoute(
            path: AppRoutes.results,
            name: 'results',
            builder: (context, state) => const _ResultsPage(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            builder: (context, state) => const _NotificationsPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const _SettingsPage(),
          ),
        ],
      ),

      // Organizer routes (require organizer role)
      ShellRoute(
        builder: (context, state, child) => _OrganizerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.organizerDashboard,
            name: 'organizerDashboard',
            builder: (context, state) => const _OrganizerDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.organizerTournaments,
            name: 'organizerTournaments',
            builder: (context, state) => const _OrganizerTournamentListPage(),
          ),
          GoRoute(
            path: AppRoutes.organizerCreateTournament,
            name: 'organizerCreateTournament',
            builder: (context, state) => const _OrganizerCreateTournamentPage(),
          ),
          GoRoute(
            path: AppRoutes.organizerTournamentDetail,
            name: 'organizerTournamentDetail',
            builder: (context, state) {
              final tournamentId = state.pathParameters['tournamentId']!;
              return _OrganizerTournamentDetailPage(tournamentId: tournamentId);
            },
          ),
          GoRoute(
            path: AppRoutes.organizerMatches,
            name: 'organizerMatches',
            builder: (context, state) {
              final tournamentId = state.pathParameters['tournamentId']!;
              return _OrganizerMatchesPage(tournamentId: tournamentId);
            },
          ),
          GoRoute(
            path: AppRoutes.organizerMatchDetail,
            name: 'organizerMatchDetail',
            builder: (context, state) {
              final matchId = state.pathParameters['matchId']!;
              return _OrganizerMatchDetailPage(matchId: matchId);
            },
          ),
          GoRoute(
            path: AppRoutes.organizerResults,
            name: 'organizerResults',
            builder: (context, state) {
              final tournamentId = state.pathParameters['tournamentId']!;
              return _OrganizerResultsPage(tournamentId: tournamentId);
            },
          ),
          GoRoute(
            path: AppRoutes.organizerAnnouncements,
            name: 'organizerAnnouncements',
            builder: (context, state) {
              final tournamentId = state.pathParameters['tournamentId']!;
              return _OrganizerAnnouncementsPage(tournamentId: tournamentId);
            },
          ),
          GoRoute(
            path: AppRoutes.organizerOrganization,
            name: 'organizerOrganization',
            builder: (context, state) => const _OrganizerOrganizationPage(),
          ),
        ],
      ),

      // Admin routes (require admin role)
      ShellRoute(
        builder: (context, state, child) => _AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            name: 'adminDashboard',
            builder: (context, state) => const _AdminDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            name: 'adminUsers',
            builder: (context, state) => const _AdminUsersPage(),
          ),
          GoRoute(
            path: AppRoutes.adminOrganizers,
            name: 'adminOrganizers',
            builder: (context, state) => const _AdminOrganizersPage(),
          ),
          GoRoute(
            path: AppRoutes.adminTournaments,
            name: 'adminTournaments',
            builder: (context, state) => const _AdminTournamentsPage(),
          ),
          GoRoute(
            path: AppRoutes.adminModerators,
            name: 'adminModerators',
            builder: (context, state) => const _AdminModeratorsPage(),
          ),
          GoRoute(
            path: AppRoutes.adminAbuse,
            name: 'adminAbuse',
            builder: (context, state) => const _AdminAbusePage(),
          ),
          GoRoute(
            path: AppRoutes.adminAudit,
            name: 'adminAudit',
            builder: (context, state) => const _AdminAuditPage(),
          ),
          GoRoute(
            path: AppRoutes.adminSettings,
            name: 'adminSettings',
            builder: (context, state) => const _AdminSettingsPage(),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
    // Redirect logic (auth guards)
    redirect: _routeGuard,
  );

  /// Route guard for authentication and authorization
  static String? _routeGuard(BuildContext context, GoRouterState state) {
    final isLoggedIn = false; // TODO: Replace with actual auth state
    final isOrganizer = false; // TODO: Check organizer role
    final isAdmin = false; // TODO: Check admin role

    final location = state.uri.toString();

    // Auth routes - redirect to home if already logged in
    final authRoutes = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.passwordReset,
      AppRoutes.passwordResetConfirm,
    ];
    final isAuthRoute = authRoutes.any((route) => location.startsWith(route));

    if (isAuthRoute && isLoggedIn) {
      return AppRoutes.home;
    }

    // Protected routes - redirect to login if not logged in
    final protectedPrefixes = [
      AppRoutes.profile,
      AppRoutes.myTournaments,
      AppRoutes.myTeams,
      AppRoutes.createTeam,
      AppRoutes.matches,
      AppRoutes.results,
      AppRoutes.notifications,
      AppRoutes.settings,
    ];
    final isProtectedRoute = protectedPrefixes.any((prefix) => location.startsWith(prefix));

    if (isProtectedRoute && !isLoggedIn) {
      return '${AppRoutes.login}?redirect=${Uri.encodeComponent(location)}';
    }

    // Organizer routes
    final organizerPrefixes = [
      AppRoutes.organizerDashboard,
      AppRoutes.organizerTournaments,
      AppRoutes.organizerCreateTournament,
      AppRoutes.organizerTournamentDetail,
      AppRoutes.organizerMatches,
      AppRoutes.organizerMatchDetail,
      AppRoutes.organizerResults,
      AppRoutes.organizerAnnouncements,
      AppRoutes.organizerOrganization,
    ];
    final isOrganizerRoute = organizerPrefixes.any((prefix) => location.startsWith(prefix));

    if (isOrganizerRoute) {
      if (!isLoggedIn) {
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(location)}';
      }
      if (!isOrganizer) {
        return AppRoutes.home; // Or show permission denied
      }
    }

    // Admin routes
    final adminPrefixes = [
      AppRoutes.adminDashboard,
      AppRoutes.adminUsers,
      AppRoutes.adminOrganizers,
      AppRoutes.adminTournaments,
      AppRoutes.adminModerators,
      AppRoutes.adminAbuse,
      AppRoutes.adminAudit,
      AppRoutes.adminSettings,
    ];
    final isAdminRoute = adminPrefixes.any((prefix) => location.startsWith(prefix));

    if (isAdminRoute) {
      if (!isLoggedIn) {
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(location)}';
      }
      if (!isAdmin) {
        return AppRoutes.home; // Or show permission denied
      }
    }

    return null; // Allow navigation
  }
}

// ===========================================================================
// PLACEHOLDER PAGES (Will be implemented in Phase 2+)
// ===========================================================================

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('FFT', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'Independent Free Fire India\nTournament Platform',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'FFT is an independent tournament management platform.\nIt is not affiliated with, endorsed by, or operated by Garena.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.tournaments),
              icon: const Icon(Icons.list),
              label: const Text('Browse Tournaments'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentListPage extends StatelessWidget {
  const _TournamentListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: const Center(child: Text('Tournament List - Phase 3')),
    );
  }
}

class _TournamentDetailPage extends StatelessWidget {
  final String tournamentId;
  const _TournamentDetailPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournament Detail')),
      body: Center(child: Text('Tournament: $tournamentId - Phase 3')),
    );
  }
}

class _StaticPage extends StatelessWidget {
  final String title;
  final String assetPath;
  const _StaticPage({required this.title, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Static Page - Phase 1')),
    );
  }
}

class _SupportPage extends StatelessWidget {
  const _SupportPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: const Center(child: Text('Support Page - Phase 2')),
    );
  }
}

class _AccountDeletionPage extends StatelessWidget {
  const _AccountDeletionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Deletion')),
      body: const Center(child: Text('Account Deletion - Phase 2')),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Page - Phase 2')),
    );
  }
}

class _RegisterPage extends StatelessWidget {
  const _RegisterPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(child: Text('Register Page - Phase 2')),
    );
  }
}

class _PasswordResetRequestPage extends StatelessWidget {
  const _PasswordResetRequestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: const Center(child: Text('Password Reset Request - Phase 2')),
    );
  }
}

class _PasswordResetConfirmPage extends StatelessWidget {
  const _PasswordResetConfirmPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Reset')),
      body: const Center(child: Text('Password Reset Confirm - Phase 2')),
    );
  }
}

class _EmailVerifyPage extends StatelessWidget {
  const _EmailVerifyPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: const Center(child: Text('Email Verification - Phase 2')),
    );
  }
}

class _AuthenticatedShell extends StatelessWidget {
  final Widget child;
  const _AuthenticatedShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(child: child);
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page - Phase 2')),
    );
  }
}

class _ProfileEditPage extends StatelessWidget {
  const _ProfileEditPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile - Phase 2')),
    );
  }
}

class _MyTournamentsPage extends StatelessWidget {
  const _MyTournamentsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tournaments')),
      body: const Center(child: Text('My Tournaments - Phase 4')),
    );
  }
}

class _MyTeamsPage extends StatelessWidget {
  const _MyTeamsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: const Center(child: Text('My Teams - Phase 4')),
    );
  }
}

class _TeamDetailPage extends StatelessWidget {
  final String teamId;
  const _TeamDetailPage({required this.teamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Detail')),
      body: Center(child: Text('Team: $teamId - Phase 4')),
    );
  }
}

class _CreateTeamPage extends StatelessWidget {
  const _CreateTeamPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: const Center(child: Text('Create Team - Phase 4')),
    );
  }
}

class _TeamInvitePage extends StatelessWidget {
  final String token;
  const _TeamInvitePage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Invitation')),
      body: Center(child: Text('Invitation Token: $token - Phase 4')),
    );
  }
}

class _MatchesPage extends StatelessWidget {
  const _MatchesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: const Center(child: Text('Matches - Phase 5')),
    );
  }
}

class _MatchDetailPage extends StatelessWidget {
  final String matchId;
  const _MatchDetailPage({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Detail')),
      body: Center(child: Text('Match: $matchId - Phase 5')),
    );
  }
}

class _ResultsPage extends StatelessWidget {
  const _ResultsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: const Center(child: Text('Results - Phase 6')),
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications - Phase 7')),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings - Phase 2')),
    );
  }
}

class _OrganizerShell extends StatelessWidget {
  final Widget child;
  const _OrganizerShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Dashboard')),
      body: child,
    );
  }
}

class _OrganizerDashboardPage extends StatelessWidget {
  const _OrganizerDashboardPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Organizer Dashboard - Phase 3'));
  }
}

class _OrganizerTournamentListPage extends StatelessWidget {
  const _OrganizerTournamentListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tournaments')),
      body: const Center(child: Text('Organizer Tournament List - Phase 3')),
    );
  }
}

class _OrganizerCreateTournamentPage extends StatelessWidget {
  const _OrganizerCreateTournamentPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: const Center(child: Text('Create Tournament - Phase 3')),
    );
  }
}

class _OrganizerTournamentDetailPage extends StatelessWidget {
  final String tournamentId;
  const _OrganizerTournamentDetailPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournament Management')),
      body: Center(child: Text('Organizer Tournament: $tournamentId - Phase 3')),
    );
  }
}

class _OrganizerMatchesPage extends StatelessWidget {
  final String tournamentId;
  const _OrganizerMatchesPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Management')),
      body: Center(child: Text('Matches for Tournament: $tournamentId - Phase 5')),
    );
  }
}

class _OrganizerMatchDetailPage extends StatelessWidget {
  final String matchId;
  const _OrganizerMatchDetailPage({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Detail')),
      body: Center(child: Text('Organizer Match: $matchId - Phase 5')),
    );
  }
}

class _OrganizerResultsPage extends StatelessWidget {
  final String tournamentId;
  const _OrganizerResultsPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results Management')),
      body: Center(child: Text('Results for Tournament: $tournamentId - Phase 6')),
    );
  }
}

class _OrganizerAnnouncementsPage extends StatelessWidget {
  final String tournamentId;
  const _OrganizerAnnouncementsPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Center(child: Text('Announcements for Tournament: $tournamentId - Phase 3')),
    );
  }
}

class _OrganizerOrganizationPage extends StatelessWidget {
  const _OrganizerOrganizationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Settings')),
      body: const Center(child: Text('Organization Settings - Phase 3')),
    );
  }
}

class _AdminShell extends StatelessWidget {
  final Widget child;
  const _AdminShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: child,
    );
  }
}

class _AdminDashboardPage extends StatelessWidget {
  const _AdminDashboardPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Admin Dashboard - Phase 7'));
  }
}

class _AdminUsersPage extends StatelessWidget {
  const _AdminUsersPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: const Center(child: Text('Admin Users - Phase 7')),
    );
  }
}

class _AdminOrganizersPage extends StatelessWidget {
  const _AdminOrganizersPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Management')),
      body: const Center(child: Text('Admin Organizers - Phase 7')),
    );
  }
}

class _AdminTournamentsPage extends StatelessWidget {
  const _AdminTournamentsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournament Oversight')),
      body: const Center(child: Text('Admin Tournaments - Phase 7')),
    );
  }
}

class _AdminModeratorsPage extends StatelessWidget {
  const _AdminModeratorsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderator Management')),
      body: const Center(child: Text('Admin Moderators - Phase 7')),
    );
  }
}

class _AdminAbusePage extends StatelessWidget {
  const _AdminAbusePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abuse Reports')),
      body: const Center(child: Text('Admin Abuse - Phase 7')),
    );
  }
}

class _AdminAuditPage extends StatelessWidget {
  const _AdminAuditPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: const Center(child: Text('Admin Audit - Phase 7')),
    );
  }
}

class _AdminSettingsPage extends StatelessWidget {
  const _AdminSettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Settings')),
      body: const Center(child: Text('Admin Settings - Phase 7')),
    );
  }
}

class _AuthCallbackPage extends StatelessWidget {
  const _AuthCallbackPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Completing sign in...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scaffold with bottom navigation bar for authenticated user area
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Tournaments',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Teams',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/my-tournaments') || location.startsWith('/tournaments')) return 0;
    if (location.startsWith('/my-teams') || location.startsWith('/teams')) return 1;
    if (location.startsWith('/matches')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.myTournaments);
        break;
      case 1:
        context.go(AppRoutes.myTeams);
        break;
      case 2:
        context.go(AppRoutes.matches);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }
}