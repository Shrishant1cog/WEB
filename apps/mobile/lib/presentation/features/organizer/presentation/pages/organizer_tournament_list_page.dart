/// Organizer tournament list (all tournaments the user can manage).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class OrganizerTournamentListPage extends StatefulWidget {
  const OrganizerTournamentListPage({super.key});

  @override
  State<OrganizerTournamentListPage> createState() =>
      _OrganizerTournamentListPageState();
}

class _OrganizerTournamentListPageState
    extends State<OrganizerTournamentListPage> {
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
      appBar: AppBar(title: const Text("My tournaments")),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create tournament",
        onPressed: () async {
          await context.push(AppRoutes.organizerCreateTournament);
          _reload();
        },
        child: const Icon(Icons.add),
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
            return const EmptyView(
              icon: Icons.emoji_events_outlined,
              title: "No tournaments",
              message: "Create your first tournament to get started.",
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: tournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return Card(
                child: ListTile(
                  title: Text(tournament.title),
                  subtitle: Text(
                    "${statusLabel(tournament.status)} · "
                    "${formatFormat(tournament.format, tournament.teamSize)}",
                  ),
                  trailing: StatusChip(status: tournament.status),
                  onTap: () async {
                    await context.push(
                      "/organizer/tournaments/${tournament.id}",
                    );
                    _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
