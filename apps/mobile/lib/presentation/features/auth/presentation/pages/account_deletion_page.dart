/// Account Deletion Page
/// Permanent account deletion with confirmation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../presentation/shared/widgets/fft_button.dart';
import '../../../../../../presentation/shared/widgets/fft_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _confirmDeletion = false;
  bool _understandDataLoss = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_confirmDeletion || !_understandDataLoss) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    context.read<AuthBloc>().add(AuthDeleteAccountRequested(
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          // Account deleted successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Your account has been permanently deleted'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.go('/');
        } else if (state.status == AuthStatus.failure && state.error != null) {
          setState(() {
            _isLoading = false;
            _error = state.error;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delete Account'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Delete Your Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'This action is permanent and cannot be undone. Please read the following carefully:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Consequences
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What will be deleted:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildConsequenceItem('Your profile and personal information'),
                        _buildConsequenceItem('All tournament registrations and history'),
                        _buildConsequenceItem('Team memberships and match records'),
                        _buildConsequenceItem('Avatar and uploaded files'),
                        _buildConsequenceItem('Notification preferences and settings'),
                        const SizedBox(height: 12),
                        Text(
                          'Data Retention:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildConsequenceItem('Anonymized match results may be retained for tournament integrity'),
                        _buildConsequenceItem('Audit logs are retained for legal compliance (DPDP)'),
                        _buildConsequenceItem('Financial records (if any) retained per tax regulations'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirmation Checkboxes
                  CheckboxListTile(
                    value: _confirmDeletion,
                    onChanged: (value) => setState(() => _confirmDeletion = value ?? false),
                    title: const Text('I understand this action is permanent and cannot be undone'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _understandDataLoss,
                    onChanged: (value) => setState(() => _understandDataLoss = value ?? false),
                    title: const Text('I understand all my data will be permanently deleted'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // Password Confirmation
                  Text(
                    'Enter your password to confirm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FFTTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your current password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  FFTTextField(
                    controller: _confirmController,
                    label: 'Type "DELETE" to confirm',
                    hint: 'DELETE',
                    prefixIcon: Icons.delete_outlined,
                    validator: (value) {
                      if (value != 'DELETE') {
                        return 'Type DELETE to confirm';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_error != null) const SizedBox(height: 16),

                  FFTButton(
                    text: 'Permanently Delete Account',
                    onPressed: (_confirmDeletion && _understandDataLoss && !_isLoading) ? _onSubmit : null,
                    isLoading: _isLoading,
                    variant: ButtonVariant.destructive,
                    size: ButtonSize.lg,
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel - Keep My Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsequenceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
