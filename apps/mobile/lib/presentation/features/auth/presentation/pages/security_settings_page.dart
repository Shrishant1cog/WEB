/// Security Settings Page
/// Manage MFA, password, sessions

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../data/models/auth_models.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../presentation/shared/widgets/fft_button.dart';
import '../../../../../../presentation/shared/widgets/fft_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'mfa_enroll_page.dart';
import 'mfa_challenge_page.dart';
import 'change_password_page.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthListMfaFactorsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two-Factor Authentication Section
                  _buildSectionHeader('Two-Factor Authentication'),
                  const SizedBox(height: 12),
                  _buildMfaSection(state),
                  const SizedBox(height: 24),

                  // Password Section
                  _buildSectionHeader('Password'),
                  const SizedBox(height: 12),
                  _buildPasswordSection(),
                  const SizedBox(height: 24),

                  // Active Sessions Section
                  _buildSectionHeader('Active Sessions'),
                  const SizedBox(height: 12),
                  _buildSessionsSection(),
                  const SizedBox(height: 24),

                  // Danger Zone
                  _buildSectionHeader('Danger Zone', isDanger: true),
                  const SizedBox(height: 12),
                  _buildDangerZone(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDanger ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Widget _buildMfaSection(AuthState state) {
    final hasMfa = state.mfaFactors.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasMfa ? 'Enabled' : 'Disabled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasMfa
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasMfa
                          ? 'Your account is protected with 2FA'
                          : 'Add an extra layer of security to your account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (!hasMfa)
                  FFTButton(
                    text: 'Enable 2FA',
                    onPressed: () => context.push('/security/mfa/enroll'),
                    variant: ButtonVariant.outlined,
                  )
                else
                  FFTButton(
                    text: 'Manage',
                    onPressed: () => _showMfaManagement(state.mfaFactors),
                    variant: ButtonVariant.outlined,
                  ),
              ],
            ),
            if (hasMfa) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ...state.mfaFactors.map((factor) => _buildMfaFactorItem(factor)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMfaFactorItem(MfaFactorModel factor) {
    final isTotp = factor.factorType == 'totp';
    final isVerified = factor.status == 'verified';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isVerified
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isTotp ? Icons.smartphone : Icons.security,
          color: isVerified
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        isTotp ? 'Authenticator App' : 'Security Key',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        isVerified ? 'Verified' : 'Not verified',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isVerified
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'remove') {
            _confirmRemoveMfa(factor.id);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20),
                SizedBox(width: 8),
                Text('Remove'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMfaManagement(List<MfaFactorModel> factors) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage 2FA',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...factors.map((factor) => ListTile(
                  leading: Icon(factor.factorType == 'totp' ? Icons.smartphone : Icons.security),
                  title: Text(factor.factorType == 'totp' ? 'Authenticator App' : 'Security Key'),
                  subtitle: Text(factor.status == 'verified' ? 'Verified' : 'Not verified'),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmRemoveMfa(factor.id);
                    },
                    child: const Text('Remove'),
                  ),
                )),
            const SizedBox(height: 16),
            FFTButton(
              text: 'Add Another Method',
              onPressed: () {
                Navigator.pop(context);
                context.push('/security/mfa/enroll');
              },
              variant: ButtonVariant.outlined,
              size: ButtonSize.lg,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMfa(String factorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove 2FA Method?'),
        content: const Text(
          'This will remove this two-factor authentication method from your account. '
          'You will need to set up 2FA again if you want to keep your account protected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthUnenrollMfaFactorRequested(factorId: factorId));
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Update your password regularly for security',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                FFTButton(
                  text: 'Change Password',
                  onPressed: () => context.push('/security/password'),
                  variant: ButtonVariant.outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Sessions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View and revoke active sessions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                FFTButton(
                  text: 'View Sessions',
                  onPressed: () => _showSessionsDialog(),
                  variant: ButtonVariant.outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: const SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('This Device'),
                subtitle: Text('Active now'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.laptop),
                title: Text('Chrome on Windows'),
                subtitle: Text('Last active 2 hours ago'),
                trailing: TextButton(
                  onPressed: null,
                  child: Text('Revoke'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Permanently delete your account and all associated data. This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FFTButton(
              text: 'Delete Account',
              onPressed: () => context.push('/account/delete'),
              variant: ButtonVariant.outlined,
              size: ButtonSize.lg,
            ),
          ],
        ),
      ),
    );
  }
}