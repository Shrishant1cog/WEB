/// Profile Page
/// User profile view and settings

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthLoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == const AuthStatus.failure() && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.go('/profile/edit'),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final profile = state.profile;
              if (profile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName[0].toUpperCase()
                                  : '?',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (profile.username != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '@${profile.username}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (profile.inGameName != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'In-Game: ${profile.inGameName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (profile.inGameUid != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'UID: ${profile.inGameUid}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSettingsSection(context, state),
                    const SizedBox(height: 24),
                    _buildDangerZone(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.person_outlined),
          title: const Text('Edit Profile'),
          subtitle: const Text('Change display name, username, in-game info'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/profile/edit'),
        ),
        ListTile(
          leading: const Icon(Icons.security_outlined),
          title: const Text('Security'),
          subtitle: const Text('Password, MFA, email'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/profile/security'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Notifications'),
          subtitle: const Text('Manage notification preferences'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/profile/notifications'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy'),
          subtitle: const Text('Profile visibility, data sharing'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/profile/privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Support'),
          subtitle: const Text('Contact us, FAQ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/support'),
        ),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/terms'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/privacy'),
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          title: Text(
            'Delete Account',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Permanently delete your account and all data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/account-deletion');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}