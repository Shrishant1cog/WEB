/// Organizer tournament management: lifecycle, entries and waitlist.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class OrganizerTournamentDetailPage extends StatefulWidget {
  const OrganizerTournamentDetailPage({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<OrganizerTournamentDetailPage> createState() =>
      _OrganizerTournamentDetailPageState();
}

class _OrganizerTournamentDetailPageState
    extends State<OrganizerTournamentDetailPage> {
  late Future<(Tournament, List<TournamentEntry>)> _future;
  bool _busy = false;

  static const Map<String, List<String>> _transitions = {
    "draft": ["published"],
    "published": ["registration_open"],
    "registration_open": ["registration_closed"],
    "registration_closed": ["registration_open", "in_progress"],
    "in_progress": ["completed"],
    "completed": [],
    "cancelled": [],
  };

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Tournament, List<TournamentEntry>)> _load() async {
    final tournamentResult =
        await tournamentRepository.getTournament(widget.tournamentId);
    final tournament = tournamentResult.getOrElse(
      () => throw tournamentResult.failure!,
    );
    final entriesResult =
        await tournamentRepository.getTournamentEntries(widget.tournamentId);
    final entries = entriesResult.getOrElse(() => const <TournamentEntry>[]);
    return (tournament, entries);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _setStatus(String status, {String? reason}) async {
    if (status == "cancelled") {
      final reasonController = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Cancel tournament"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "All active entries will be cancelled. This cannot be undone.",
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: "Reason (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Keep tournament"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Cancel tournament"),
            ),
          ],
        ),
      );
      reason = reasonController.text.trim();
      reasonController.dispose();
      if (ok != true) return;
    }

    setState(() => _busy = true);
    final result = await tournamentRepository.setStatus(
      widget.tournamentId,
      status,
      reason: reason == null || reason.isEmpty ? null : reason,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (_) {
        showMessage(context, "Status updated to ${statusLabel(status)}.");
        _reload();
      },
    );
  }

  Future<void> _promote() async {
    setState(() => _busy = true);
    final result =
        await tournamentRepository.promoteWaitlist(widget.tournamentId);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (promoted) {
        showMessage(
          context,
          promoted == null
              ? "No waitlisted entry could be promoted."
              : "Promoted the next waitlisted entry.",
        );
        _reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage tournament")),
      body: FutureBuilder<(Tournament, List<TournamentEntry>)>(
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
          final tournament = snapshot.data!.$1;
          final entries = snapshot.data!.$2;
          return _body(tournament, entries);
        },
      ),
    );
  }

  Widget _body(Tournament tournament, List<TournamentEntry> entries) {
    final theme = Theme.of(context);
    final confirmed = entries
        .where((entry) => entry.registration.isConfirmed)
        .toList(growable: false);
    final waitlisted = entries
        .where((entry) => entry.registration.isWaitlisted)
        .toList(growable: false)
      ..sort((a, b) =>
          (a.registration.waitlistSeq ?? 0)
              .compareTo(b.registration.waitlistSeq ?? 0));
    final withdrawn = entries
        .where((entry) => entry.registration.status == "cancelled")
        .toList(growable: false);

    final transitions = _transitions[tournament.status] ?? const [];
    final canCancel = !const ["completed", "cancelled"]
        .contains(tournament.status);

    return RefreshIndicator(
      onRefresh: () async {
        _reload();
        await _future;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  tournament.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(status: tournament.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              formatFormat(tournament.format, tournament.teamSize),
              tournament.mode.toUpperCase(),
              "Capacity ${tournament.maxTeams}",
              tournament.waitlistEnabled ? "Waitlist on" : "Waitlist off",
            ].join(" · "),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push(
                      "/organizer/tournaments/${tournament.id}/edit",
                      extra: tournament,
                    );
                    _reload();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    "/tournaments/${tournament.id}",
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Public"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _stat(context, "Confirmed",
                    "${confirmed.length}/${tournament.maxTeams}"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _stat(context, "Waitlist", "${waitlisted.length}"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _stat(context, "Withdrawn", "${withdrawn.length}"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Schedule", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _scheduleRow("Registration opens",
              formatDateTime(tournament.registrationStartsAt)),
          _scheduleRow("Registration closes",
              formatDateTime(tournament.registrationEndsAt)),
          _scheduleRow("Tournament starts",
              formatDateTime(tournament.tournamentStartsAt)),
          _scheduleRow(
            "Withdrawal deadline",
            formatDateTime(
              tournament.withdrawalDeadline ?? tournament.registrationEndsAt,
            ),
          ),
          const SizedBox(height: 20),
          Text("Lifecycle", style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            "Transitions are validated server-side.",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final next in transitions)
                FilledButton.tonal(
                  onPressed: _busy ? null : () => _setStatus(next),
                  child: Text(_transitionLabel(next)),
                ),
              if (canCancel)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: _busy ? null : () => _setStatus("cancelled"),
                  child: const Text("Cancel tournament"),
                ),
            ],
          ),
          if (waitlisted.isNotEmpty &&
              const ["registration_open", "registration_closed"]
                  .contains(tournament.status)) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _busy ? null : _promote,
              icon: const Icon(Icons.arrow_upward),
              label: const Text("Promote next waitlisted"),
            ),
          ],
          const SizedBox(height: 24),
          Text("Confirmed entries", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (confirmed.isEmpty)
            Text("No confirmed entries yet.", style: theme.textTheme.bodySmall)
          else
            for (final entry in confirmed) _entryCard(entry),
          const SizedBox(height: 16),
          Text("Waitlist", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (waitlisted.isEmpty)
            Text("The waitlist is empty.", style: theme.textTheme.bodySmall)
          else
            for (var i = 0; i < waitlisted.length; i++)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${i + 1}")),
                  title: Text(waitlisted[i].label),
                  subtitle: Text(
                    "Waitlisted ${formatDateTime(
                      waitlisted[i].registration.waitlistedAt,
                    )}",
                  ),
                ),
              ),
          if (withdrawn.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Withdrawn", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final entry in withdrawn)
              Card(
                child: ListTile(
                  title: Text(entry.label),
                  subtitle: Text(
                    entry.registration.withdrawnAt == null
                        ? "Withdrawn"
                        : "Withdrawn ${formatDateTime(
                            entry.registration.withdrawnAt,
                          )}",
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _transitionLabel(String status) => switch (status) {
        "published" => "Publish",
        "registration_open" => "Open registration",
        "registration_closed" => "Close registration",
        "in_progress" => "Mark in progress",
        "completed" => "Mark completed",
        _ => statusLabel(status),
      };

  Widget _entryCard(TournamentEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  entry.registration.entryType ?? "solo",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final member in entry.members)
              Text(
                [
                  member.displayName ?? "Player",
                  if (member.role == "captain") "(captain)",
                  if (member.inGameUid != null &&
                      member.inGameUid!.isNotEmpty)
                    "UID ${member.inGameUid}",
                ].join(" · "),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _scheduleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
