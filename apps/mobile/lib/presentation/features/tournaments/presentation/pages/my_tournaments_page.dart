/// The signed-in player's tournament entries, including waitlist positions.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../tournament_helpers.dart';

class MyTournamentsPage extends StatefulWidget {
  const MyTournamentsPage({super.key});

  @override
  State<MyTournamentsPage> createState() => _MyTournamentsPageState();
}

class _MyTournamentsPageState extends State<MyTournamentsPage> {
  late Future<List<_EntryWithTournament>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_EntryWithTournament>> _load() async {
    final userId = currentUserId;
    if (userId == null) return const [];

    final entriesResult = await tournamentRepository.getMyEntries(userId);
    final entries = entriesResult.fold(
      (failure) => throw failure,
      (entries) => entries,
    );
    if (entries.isEmpty) return const [];

    final ids = entries
        .map((entry) => entry.registration.tournamentId)
        .toSet()
        .toList(growable: false);
    final tournamentsResult = await tournamentRepository.getTournamentsByIds(ids);
    final tournaments = tournamentsResult.fold(
      (_) => const <Tournament>[],
      (items) => items,
    );
    final byId = {for (final item in tournaments) item.id: item};

    return entries
        .map((entry) => _EntryWithTournament(
              entry: entry,
              tournament: byId[entry.registration.tournamentId],
            ))
        .toList(growable: false);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _withdraw(TournamentEntry entry) async {
    final ok = await confirm(
      context,
      title: "Withdraw registration",
      message: "Your entry will be cancelled and cannot be restored.",
      confirmLabel: "Withdraw",
    );
    if (!ok) return;

    final result = await tournamentRepository.withdraw(entry.registration.id);
    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (promoted) {
        showMessage(
          context,
          promoted == null
              ? "Registration withdrawn."
              : "Registration withdrawn. The next waitlisted entry was promoted.",
        );
        _reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My tournaments"),
        actions: [
          IconButton(
            tooltip: "Browse tournaments",
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.tournaments),
          ),
        ],
      ),
      body: FutureBuilder<List<_EntryWithTournament>>(
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
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return EmptyView(
              icon: Icons.confirmation_number_outlined,
              title: "No tournament entries yet",
              message: "Register for a tournament to see it here.",
              action: FilledButton.tonal(
                onPressed: () => context.go(AppRoutes.tournaments),
                child: const Text("Browse tournaments"),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final row = rows[index];
                final registration = row.entry.registration;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.tournament?.title ?? "Tournament",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            StatusChip(status: registration.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (row.tournament != null)
                          Text(
                            [
                              formatFormat(
                                row.tournament!.format,
                                row.tournament!.teamSize,
                              ),
                              row.tournament!.mode.toUpperCase(),
                              formatDateTime(
                                row.tournament!.tournamentStartsAt,
                              ),
                            ].join(" · "),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (registration.teamName != null) ...[
                          const SizedBox(height: 4),
                          Text("Team: ${registration.teamName}"),
                        ],
                        if (registration.isWaitlisted) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Waitlist position ${registration.waitlistSeq ?? "?"}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (registration.cancellationReason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            registration.cancellationReason!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => context.push(
                                "/tournaments/${registration.tournamentId}",
                              ),
                              child: const Text("View tournament"),
                            ),
                            const Spacer(),
                            if (registration.isActive)
                              TextButton(
                                onPressed: () => _withdraw(row.entry),
                                child: const Text("Withdraw"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EntryWithTournament {
  const _EntryWithTournament({required this.entry, this.tournament});

  final TournamentEntry entry;
  final Tournament? tournament;
}
