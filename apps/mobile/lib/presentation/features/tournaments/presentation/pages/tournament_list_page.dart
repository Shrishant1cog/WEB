/// Public tournament discovery: search, filters, and open registration state.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/tournament_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../../../../../presentation/shared/themes/design_tokens.dart';
import '../../../../../presentation/shared/widgets/widgets.dart';
import '../tournament_helpers.dart';

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage> {
  final _search = TextEditingController();
  late Future<List<TournamentListing>> _future;
  String _mode = 'all';
  String _status = 'all';

  // Debounce timer for search
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _reload();
      }
    });
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
        title: const Text('Tournaments'),
        actions: [
          IconButton(
            tooltip: currentUserId == null ? 'Sign in' : 'My tournaments',
            icon: Icon(
              currentUserId == null
                  ? Icons.login_rounded
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
        children: <Widget>[
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
            child: FFTTextField(
              controller: _search,
              label: 'Search tournaments',
              hint: 'Search by name...',
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              suffixIcon: _search.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _search.clear();
                        _reload();
                      },
                    )
                  : null,
              onFieldSubmitted: (_) => _reload(),
              onChanged: (_) {}, // Handled by listener
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  // Mode filters
                  ...['all', 'br', 'cs'].map((mode) => Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: FilterChip(
                      label: Text(mode == 'all' ? 'All modes' : mode.toUpperCase()),
                      selected: _mode == mode,
                      onSelected: (_) {
                        setState(() => _mode = mode);
                        _reload();
                      },
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.xs,
                      ),
                      labelStyle: TypeScale.labelMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),

                  const SizedBox(width: Spacing.md),

                  // Status filters
                  ...['all', 'registration_open', 'published'].map((status) => Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: FilterChip(
                      label: Text(status == 'all' ? 'Any status' : statusLabel(status)),
                      selected: _status == status,
                      onSelected: (_) {
                        setState(() => _status = status);
                        _reload();
                      },
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.xs,
                      ),
                      labelStyle: TypeScale.labelMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),

          const Divider(height: 1.0),

          // Tournament list
          Expanded(
            child: FutureBuilder<List<TournamentListing>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const FFTTournamentListSkeleton();
                }
                if (snapshot.hasError) {
                  return FFTErrorState(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                    retryLabel: 'Retry',
                  );
                }
                final listings = snapshot.data ?? const <TournamentListing>[];
                if (listings.isEmpty) {
                  return FFTEmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'No tournaments found',
                    message: 'Try a different search or filter.',
                    action: TextButton(
                      onPressed: () {
                        _search.clear();
                        _mode = 'all';
                        _status = 'all';
                        _reload();
                      },
                      child: const Text('Reset filters'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Spacing.md),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                    itemBuilder: (context, index) =>
                        FFTTournamentCard(
                          listing: listings[index],
                          onTap: () => context.push('/tournaments/${listings[index].id}'),
                        ),
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