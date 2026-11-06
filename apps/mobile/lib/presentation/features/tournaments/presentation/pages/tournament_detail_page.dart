/// Tournament detail with registration, team selection and withdrawal.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../data/models/team_models.dart';
import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../tournament_helpers.dart';

class TournamentDetailPage extends StatefulWidget {
  const TournamentDetailPage({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  late Future<(TournamentListing, TournamentEntry?)> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(TournamentListing, TournamentEntry?)> _load() async {
    final listingResult =
        await tournamentRepository.getPublicTournament(widget.tournamentId);
    if (listingResult.isLeft()) throw listingResult.failure!;
    final listing = listingResult.getOrElse(() => throw StateError("missing"));

    TournamentEntry? entry;
    final userId = currentUserId;
    if (userId != null) {
      final entriesResult = await tournamentRepository.getMyEntries(userId);
      entry = entriesResult.fold(
        (_) => null,
        (entries) {
          for (final item in entries) {
            if (item.registration.tournamentId == widget.tournamentId &&
                item.registration.isActive) {
              return item;
            }
          }
          return null;
        },
      );
    }
    return (listing, entry);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _register(TournamentListing listing) async {
    final userId = currentUserId;
    if (userId == null) {
      context.go("${AppRoutes.login}?redirect=${Uri.encodeComponent(
        "/tournaments/${listing.id}",
      )}");
      return;
    }

    String? teamId;
    if (listing.requiresTeam) {
      teamId = await _pickTeam(listing);
      if (teamId == null) return;
    }

    setState(() => _busy = true);
    final result =
        await tournamentRepository.register(listing.id, teamId: teamId);
    setState(() => _busy = false);

    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (registration) {
        showMessage(
          context,
          registration.isWaitlisted
              ? "Tournament is full — you are on the waitlist at position "
                  "${registration.waitlistPosition ?? "?"}."
              : "Registration confirmed.",
        );
        _reload();
      },
    );
  }

  Future<String?> _pickTeam(TournamentListing listing) async {
    final userId = currentUserId!;
    final teamsResult = await teamRepository.getMyTeams(userId);
    final teams = teamsResult.getOrElse(() => const <Team>[]);
    final captainTeams =
        teams.where((team) => team.isCaptain(userId)).toList(growable: false);

    if (!mounted) return null;
    if (captainTeams.isEmpty) {
      showMessage(
        context,
        "Create a team and become its captain before registering.",
        error: true,
      );
      return null;
    }

    final counts = (await teamRepository.getMemberCounts(
      captainTeams.map((team) => team.id).toList(),
    )).getOrElse(() => const <String, int>{});

    if (!mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Choose a team"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "This tournament requires exactly ${listing.teamSize} players.",
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final team in captainTeams)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(team.name),
                subtitle: Text(
                  "${counts[team.id] ?? 0}/${listing.teamSize} players"
                  "${(counts[team.id] ?? 0) == listing.teamSize ? "" : " · roster incomplete"}",
                ),
                enabled: (counts[team.id] ?? 0) == listing.teamSize,
                onTap: () => Navigator.of(dialogContext).pop(team.id),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw(TournamentEntry entry) async {
    final ok = await confirm(
      context,
      title: "Withdraw registration",
      message: "Your entry will be cancelled. If you are on the waitlist you "
          "will lose your place.",
      confirmLabel: "Withdraw",
    );
    if (!ok) return;

    setState(() => _busy = true);
    final result = await tournamentRepository.withdraw(entry.registration.id);
    setState(() => _busy = false);
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
      appBar: AppBar(title: const Text("Tournament")),
      body: FutureBuilder<(TournamentListing, TournamentEntry?)>(
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
          final listing = snapshot.data!.$1;
          final entry = snapshot.data!.$2;
          return _body(listing, entry);
        },
      ),
    );
  }

  Widget _body(TournamentListing listing, TournamentEntry? entry) {
    final theme = Theme.of(context);
    final registrationOpen = listing.status == "registration_open";
    final now = DateTime.now();

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
                child: Text(listing.title, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(width: 8),
              StatusChip(status: listing.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              formatFormat(listing.format, listing.teamSize),
              listing.mode.toUpperCase(),
              if (listing.map != null && listing.map!.isNotEmpty) listing.map!,
            ].join(" · "),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text("Organized by ${listing.organizerName}",
              style: theme.textTheme.bodySmall),
          if (listing.description != null &&
              listing.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(listing.description!),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(
                    Icons.event_outlined,
                    "Starts",
                    formatDateTime(listing.tournamentStartsAt),
                  ),
                  _infoRow(
                    Icons.how_to_reg_outlined,
                    "Registration",
                    "${formatDateTime(listing.registrationStartsAt)} → "
                        "${formatDateTime(listing.registrationEndsAt)}",
                  ),
                  _infoRow(
                    Icons.groups_outlined,
                    "Capacity",
                    "${listing.confirmedEntries}/${listing.maxTeams} entries"
                        "${listing.isFull ? " (full)" : ""}",
                  ),
                  if (listing.waitlistedEntries > 0)
                    _infoRow(
                      Icons.hourglass_bottom,
                      "Waitlist",
                      "${listing.waitlistedEntries} waiting",
                    ),
                  _infoRow(
                    Icons.workspace_premium_outlined,
                    "Prize",
                    listing.prizePool == null || listing.prizePool!.isEmpty
                        ? "—"
                        : listing.prizePool!,
                  ),
                  _infoRow(
                    Icons.timer_outlined,
                    "Withdrawal deadline",
                    formatDateTime(
                      listing.withdrawalDeadline ??
                          listing.registrationEndsAt,
                    ),
                  ),
                  _infoRow(
                    Icons.badge_outlined,
                    "In-game UID",
                    listing.requiresInGameId ? "Required" : "Not required",
                  ),
                ],
              ),
            ),
          ),
          if (listing.rulesText != null && listing.rulesText!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Rules", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(listing.rulesText!),
          ],
          if (listing.contactInfo != null && listing.contactInfo!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Contact", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(listing.contactInfo!),
          ],
          const SizedBox(height: 24),
          if (entry != null) ...[
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: Icon(
                  entry.registration.isConfirmed
                      ? Icons.verified_outlined
                      : Icons.hourglass_bottom,
                ),
                title: Text(
                  entry.registration.isConfirmed
                      ? "You are registered"
                      : "You are on the waitlist"
                      "${entry.registration.waitlistSeq == null ? "" : " (#${entry.registration.waitlistSeq})"}",
                ),
                subtitle: entry.registration.teamName == null
                    ? null
                    : Text("Team: ${entry.registration.teamName}"),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _withdraw(entry),
              icon: const Icon(Icons.logout),
              label: const Text("Withdraw registration"),
            ),
          ] else if (currentUserId == null)
            FilledButton(
              onPressed: () => context.go(
                "${AppRoutes.login}?redirect=${Uri.encodeComponent(
                  "/tournaments/${listing.id}",
                )}",
              ),
              child: const Text("Sign in to register"),
            )
          else if (registrationOpen)
            FilledButton.icon(
              onPressed: _busy ? null : () => _register(listing),
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.how_to_reg),
              label: Text(
                listing.isFull && !listing.waitlistEnabled
                    ? "Tournament full"
                    : listing.isFull
                        ? "Join waitlist"
                        : "Register",
              ),
            )
          else
            Text(
              listing.status == "registration_closed"
                  ? "Registration is closed."
                  : now.isBefore(listing.registrationStartsAt)
                      ? "Registration opens ${formatDateTime(listing.registrationStartsAt)}."
                      : "Registration is not open yet.",
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
