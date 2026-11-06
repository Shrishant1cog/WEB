/// Public tournament discovery: search, filters, and open registration state.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../tournament_helpers.dart';

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage> {
  final _search = TextEditingController();
  late Future<List<TournamentListing>> _future;
  String _mode = "all";
  String _status = "all";

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<TournamentListing>> _load() async {
    final result = await tournamentRepository.getPublicTournaments(
      query: _search.text,
      mode: _mode,
      status: _status,
    );
    return result.fold((failure) => throw failure, (listings) => listings);
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
        title: const Text("Tournaments"),
        actions: [
          IconButton(
            tooltip: currentUserId == null ? "Sign in" : "My tournaments",
            icon: Icon(
              currentUserId == null
                  ? Icons.login
                  : Icons.confirmation_number_outlined,
            ),
            onPressed: () => context.go(
              currentUserId == null
                  ? AppRoutes.login
                  : AppRoutes.myTournaments,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search tournaments",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          _reload();
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _reload(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                for (final mode in const ["all", "br", "cs"])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(mode == "all" ? "All modes" : mode.toUpperCase()),
                      selected: _mode == mode,
                      onSelected: (_) {
                        _mode = mode;
                        _reload();
                      },
                    ),
                  ),
                const SizedBox(width: 12),
                for (final status in const [
                  "all",
                  "registration_open",
                  "published",
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status == "all" ? "Any status" : statusLabel(status)),
                      selected: _status == status,
                      onSelected: (_) {
                        _status = status;
                        _reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<TournamentListing>>(
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
                final listings = snapshot.data ?? const <TournamentListing>[];
                if (listings.isEmpty) {
                  return EmptyView(
                    icon: Icons.emoji_events_outlined,
                    title: "No tournaments found",
                    message: "Try a different search or filter.",
                    action: TextButton(
                      onPressed: () {
                        _search.clear();
                        _mode = "all";
                        _status = "all";
                        _reload();
                      },
                      child: const Text("Reset filters"),
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
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _TournamentCard(listing: listings[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard({required this.listing});

  final TournamentListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push("/tournaments/${listing.id}"),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: listing.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  formatFormat(listing.format, listing.teamSize),
                  listing.mode.toUpperCase(),
                  if (listing.map != null && listing.map!.isNotEmpty)
                    listing.map!,
                  "by ${listing.organizerName}",
                ].join(" · "),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formatDateTime(listing.tournamentStartsAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const Icon(Icons.groups_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "${listing.confirmedEntries}/${listing.maxTeams}",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (listing.isFull)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text("Full"),
                    ),
                  if (listing.prizePool != null &&
                      listing.prizePool!.isNotEmpty) ...[
                    const Icon(Icons.workspace_premium_outlined, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        listing.prizePool!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
