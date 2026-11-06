/// Accept or decline a team invitation from a one-time token.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class TeamInvitePage extends StatefulWidget {
  const TeamInvitePage({super.key, required this.token});

  final String token;

  @override
  State<TeamInvitePage> createState() => _TeamInvitePageState();
}

class _TeamInvitePageState extends State<TeamInvitePage> {
  bool _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    final result = await teamRepository.acceptInvitation(widget.token);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (teamId) {
        showMessage(context, "You joined the team.");
        context.pushReplacement("/teams/$teamId");
      },
    );
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    final result = await teamRepository.declineInvitation(widget.token);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => showMessage(context, failure.message, error: true),
      (_) {
        showMessage(context, "Invitation declined.");
        context.go(AppRoutes.myTeams);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Team invitation")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "You have been invited to join a team",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Accepting adds you to the roster. The captain can then register "
              "the team for squad tournaments.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _busy ? null : _accept,
              icon: const Icon(Icons.check),
              label: const Text("Accept invitation"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _decline,
              child: const Text("Decline"),
            ),
            const SizedBox(height: 24),
            SelectableText(
              "Token: ${widget.token}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
