/// Organizer dashboard: tournaments they help run.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  late Future<List<Tournament>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Tournament>> _load() async {
    final userId = currentUserId;
    if (userId == null) return const [];
    final result = await tournamentRepository.getOrganizerTournaments(userId);
    return result.fold((failure) => throw failure, (items) => items);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organizer"),
        actions: [
          IconButton(
            tooltip: "Player area",
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(AppRoutes.myTournaments),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.organizerCreateTournament);
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text("Create tournament"),
      ),
      body: FutureBuilder<List<Tournament>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final tournaments = snapshot.data ?? const <Tournament>[];
          if (tournaments.isEmpty) {
            return EmptyView(
              icon: Icons.emoji_events_outlined,
              title: "No tournaments yet",
              message:
                  "Create a draft, configure capacity and schedule, then open "
                  "registration when you are ready.",
              action: FilledButton.icon(
                onPressed: () async {
                  await context.push(AppRoutes.organizerCreateTournament);
                  _reload();
                },
                icon: const Icon(Icons.add),
                label: const Text("Create tournament"),
              ),
            );
          }

          final open = tournaments
              .where((item) => item.status == "registration_open")
              .length;
          final drafts =
              tournaments.where((item) => item.status == "draft").length;

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _stat(
                        context,
                        "Tournaments",
                        "${tournaments.length}",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _stat(context, "Open", "$open")),
                    const SizedBox(width: 8),
                    Expanded(child: _stat(context, "Drafts", "$drafts")),
                  ],
                ),
                const SizedBox(height: 16),
                for (final tournament in tournaments) ...[
                  Card(
                    child: ListTile(
                      title: Text(tournament.title),
                      subtitle: Text(
                        [
                          statusLabel(tournament.status),
                          formatFormat(tournament.format, tournament.teamSize),
                          tournament.mode.toUpperCase(),
                          formatDateTime(tournament.tournamentStartsAt),
                        ].join(" · "),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await context.push(
                          "/organizer/tournaments/${tournament.id}",
                        );
                        _reload();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
