/// Teams the signed-in player belongs to.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/team_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class MyTeamsPage extends StatefulWidget {
  const MyTeamsPage({super.key});

  @override
  State<MyTeamsPage> createState() => _MyTeamsPageState();
}

class _MyTeamsPageState extends State<MyTeamsPage> {
  late Future<List<Team>> _future;
  Map<String, int> _counts = const {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Team>> _load() async {
    final userId = currentUserId;
    if (userId == null) return const [];
    final result = await teamRepository.getMyTeams(userId);
    final teams = result.fold((failure) => throw failure, (teams) => teams);
    if (teams.isEmpty) {
      _counts = const {};
      return teams;
    }
    final countsResult = await teamRepository.getMemberCounts(
      teams.map((team) => team.id).toList(),
    );
    _counts = countsResult.getOrElse(() => const {});
    return teams;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;
    return Scaffold(
      appBar: AppBar(title: const Text("My teams")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.createTeam);
          _reload();
        },
        icon: const Icon(Icons.group_add),
        label: const Text("Create team"),
      ),
      body: FutureBuilder<List<Team>>(
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
          final teams = snapshot.data ?? const <Team>[];
          if (teams.isEmpty) {
            return EmptyView(
              icon: Icons.groups_outlined,
              title: "No teams yet",
              message: "Create a team to register for squad tournaments.",
              action: FilledButton.icon(
                onPressed: () async {
                  await context.push(AppRoutes.createTeam);
                  _reload();
                },
                icon: const Icon(Icons.group_add),
                label: const Text("Create team"),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: teams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final team = teams[index];
                final isCaptain = userId != null && team.isCaptain(userId);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        team.name.isEmpty ? "?" : team.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(team.name),
                    subtitle: Text(
                      [
                        if (team.tag != null && team.tag!.isNotEmpty)
                          "[${team.tag}]",
                        "${_counts[team.id] ?? 0} members",
                        if (isCaptain) "You are captain",
                      ].join(" · "),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await context.push("/teams/${team.id}");
                      _reload();
                    },
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
