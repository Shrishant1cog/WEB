/// Team roster management: invitations, captaincy and membership.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../data/models/team_models.dart';
import '../../../../../injection_container.dart';
import '../../../../../presentation/shared/navigation/app_router.dart';
import '../../../tournaments/presentation/tournament_helpers.dart';

class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({super.key, required this.teamId});

  final String teamId;

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late Future<TeamDetail> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<TeamDetail> _load() async {
    final userId = currentUserId;
    if (userId == null) throw StateError("Not signed in");
    final result = await teamRepository.getTeam(widget.teamId, userId);
    return result.getOrElse(() => throw result.failure!);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _run(
    Future<bool> Function() action, {
    String? success,
  }) async {
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok && success != null) showMessage(context, success);
    if (ok) _reload();
  }

  Future<bool> _invite() async {
    final emailController = TextEditingController();
    final hoursController = TextEditingController(text: "72");
    final formKey = GlobalKey<FormState>();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Invite a player"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Player email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? "";
                  if (!text.contains("@") || !text.contains(".")) {
                    return "Enter a valid email address.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Expires in hours",
                  helperText: "1-168 hours",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final hours = int.tryParse(value ?? "");
                  if (hours == null || hours < 1 || hours > 168) {
                    return "Enter a value between 1 and 168.";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(emailController.text.trim());
              }
            },
            child: const Text("Create invitation"),
          ),
        ],
      ),
    );
    emailController.dispose();
    final hours = int.tryParse(hoursController.text) ?? 72;
    hoursController.dispose();
    if (email == null) return false;

    final result =
        await teamRepository.inviteToTeam(widget.teamId, email: email, expiresHours: hours);
    if (!mounted) return false;
    if (result.isLeft()) {
      showMessage(context, result.failure!.message, error: true);
      return false;
    }
    final token = result.getOrElse(() => "");
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Invitation created"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Share this one-time token with the player. It is only shown "
              "once and expires automatically.",
            ),
            const SizedBox(height: 12),
            SelectableText(
              token,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Navigator.of(dialogContext).pop();
              showMessage(context, "Invitation token copied.");
            },
            child: const Text("Copy token"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Done"),
          ),
        ],
      ),
    );
    return true;
  }

  Future<void> _removeMember(TeamDetail detail, TeamMember member) async {
    final ok = await confirm(
      context,
      title: "Remove member",
      message: "Remove ${member.displayName ?? "this player"} from the team?",
      confirmLabel: "Remove",
    );
    if (!ok) return;
    await _run(
      () async {
        final result =
            await teamRepository.removeMember(widget.teamId, member.userId);
        return result.fold(
          (failure) {
            showMessage(context, failure.message, error: true);
            return false;
          },
          (_) => true,
        );
      },
      success: "Member removed.",
    );
  }

  Future<void> _transfer(TeamDetail detail, TeamMember member) async {
    final ok = await confirm(
      context,
      title: "Transfer captaincy",
      message:
          "Make ${member.displayName ?? "this player"} the team captain? You will become a regular member.",
      confirmLabel: "Transfer",
    );
    if (!ok) return;
    await _run(
      () async {
        final result = await teamRepository.transferCaptaincy(
          widget.teamId,
          member.userId,
        );
        return result.fold(
          (failure) {
            showMessage(context, failure.message, error: true);
            return false;
          },
          (_) => true,
        );
      },
      success: "Captaincy transferred.",
    );
  }

  Future<void> _revoke(TeamInvitation invitation) async {
    await _run(
      () async {
        final result =
            await teamRepository.revokeInvitation(invitation.id);
        return result.fold(
          (failure) {
            showMessage(context, failure.message, error: true);
            return false;
          },
          (_) => true,
        );
      },
      success: "Invitation revoked.",
    );
  }

  Future<void> _leaveOrDissolve(TeamDetail detail) async {
    final userId = currentUserId!;
    final isCaptain = detail.team.isCaptain(userId);
    final ok = await confirm(
      context,
      title: isCaptain ? "Dissolve team" : "Leave team",
      message: isCaptain
          ? "Dissolving removes all members and cannot be undone. Active "
              "tournament registrations block this action."
          : "Leave this team?",
      confirmLabel: isCaptain ? "Dissolve" : "Leave",
    );
    if (!ok) return;

    await _run(
      () async {
        final result = isCaptain
            ? await teamRepository.dissolveTeam(widget.teamId)
            : await teamRepository.leaveTeam(widget.teamId);
        return result.fold(
          (failure) {
            showMessage(context, failure.message, error: true);
            return false;
          },
          (_) => true,
        );
      },
      success: isCaptain ? "Team dissolved." : "You left the team.",
    );
    if (mounted && isCaptain) {
      context.go(AppRoutes.myTeams);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Team")),
      body: FutureBuilder<TeamDetail>(
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
          return _body(snapshot.data!);
        },
      ),
    );
  }

  Widget _body(TeamDetail detail) {
    final theme = Theme.of(context);
    final userId = currentUserId!;
    final isCaptain = detail.isCaptain(userId);

    return RefreshIndicator(
      onRefresh: () async {
        _reload();
        await _future;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(
                  detail.team.name.isEmpty
                      ? "?"
                      : detail.team.name[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.team.name, style: theme.textTheme.titleLarge),
                    if (detail.team.tag != null &&
                        detail.team.tag!.isNotEmpty)
                      Text(
                        "[${detail.team.tag}]",
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (isCaptain)
                Chip(
                  label: const Text("Captain"),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
            ],
          ),
          if (detail.team.description != null &&
              detail.team.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(detail.team.description!),
          ],
          const SizedBox(height: 8),
          Text(
            "${detail.memberCount}/${detail.team.maxMembers} members",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (isCaptain) ...[
            FilledButton.icon(
              onPressed: _busy ? null : () => _run(_invite),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Invite player"),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.myTournaments),
              icon: const Icon(Icons.emoji_events_outlined),
              label: const Text("Register for a tournament"),
            ),
          ],
          const SizedBox(height: 20),
          Text("Roster", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final member in detail.members)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (member.displayName ?? "P").isEmpty
                        ? "P"
                        : member.displayName![0].toUpperCase(),
                  ),
                ),
                title: Text(member.displayName ?? "Player"),
                subtitle: Text(
                  [
                    member.isCaptain ? "Captain" : "Member",
                    if (member.inGameName != null &&
                        member.inGameName!.isNotEmpty)
                      member.inGameName!,
                    if (member.inGameUid != null &&
                        member.inGameUid!.isNotEmpty)
                      "UID ${member.inGameUid}",
                  ].join(" · "),
                ),
                trailing: isCaptain && member.userId != userId
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "remove") _removeMember(detail, member);
                          if (value == "transfer") _transfer(detail, member);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: "transfer",
                            child: Text("Transfer captaincy"),
                          ),
                          PopupMenuItem(
                            value: "remove",
                            child: Text("Remove from team"),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          if (isCaptain && detail.invitations.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text("Pending invitations", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final invitation in detail.invitations)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: Text(invitation.target),
                  subtitle: Text(
                    invitation.expiresAt == null
                        ? "Pending"
                        : "Expires ${formatDateTime(invitation.expiresAt)}",
                  ),
                  trailing: IconButton(
                    tooltip: "Revoke",
                    icon: const Icon(Icons.close),
                    onPressed: _busy ? null : () => _revoke(invitation),
                  ),
                ),
              ),
          ],
          if (!isCaptain) ...[
            const SizedBox(height: 8),
            Text(
              "Only the captain can invite players, manage the roster or "
              "register the team.",
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 24),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: _busy ? null : () => _leaveOrDissolve(detail),
            icon: const Icon(Icons.exit_to_app),
            label: Text(isCaptain ? "Dissolve team" : "Leave team"),
          ),
        ],
      ),
    );
  }
}
