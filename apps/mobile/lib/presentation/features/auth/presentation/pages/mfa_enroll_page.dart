/// MFA Enrollment Page
/// Enroll TOTP MFA using authenticator app

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../data/models/auth_models.dart';
import '../../../../../../presentation/shared/widgets/fft_button.dart';
import '../../../../../../presentation/shared/widgets/fft_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class MfaEnrollPage extends StatefulWidget {
  const MfaEnrollPage({super.key});

  @override
  State<MfaEnrollPage> createState() => _MfaEnrollPageState();
}

class _MfaEnrollPageState extends State<MfaEnrollPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _showSecret = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onEnroll() {
    context.read<AuthBloc>().add(const AuthEnrollMfaTotpRequested());
  }

  void _onVerify() {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AuthBloc>().state;
    if (state.mfaEnrollment == null) return;

    context.read<AuthBloc>().add(AuthVerifyMfaTotpRequested(
      factorId: state.mfaEnrollment!.factorId,
      challengeId: '', // Will be created by challenge step
      code: _codeController.text.trim(),
    ));
  }

  void _onChallengeAndVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AuthBloc>().state;
    if (state.mfaEnrollment == null) return;

    setState(() => _isLoading = true);
    setState(() => _error = null);

    // First create a challenge
    context.read<AuthBloc>().add(AuthChallengeMfaTotpRequested(
      factorId: state.mfaEnrollment!.factorId,
    ));

    // Wait for challenge to be created, then verify
    // In a real implementation, you'd use a listener or await
    // For now, we'll do it in two steps
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.mfaEnrollment && state.mfaEnrollment != null) {
          // Enrollment started, show QR code
        } else if (state.status == AuthStatus.mfaChallenge && state.mfaChallenge != null) {
          // Challenge created, now verify
          context.read<AuthBloc>().add(AuthVerifyMfaTotpRequested(
            factorId: state.mfaChallenge!.factorId,
            challengeId: state.mfaChallenge!.challengeId,
            code: _codeController.text.trim(),
          ));
        } else if (state.status == AuthStatus.authenticated && state.aalLevel == 'aal2') {
          // MFA verified successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('MFA enrolled successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.go('/security-settings');
        } else if (state.status == AuthStatus.failure && state.error != null) {
          setState(() {
            _isLoading = false;
            _error = state.error;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enable Two-Factor Authentication'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step indicator
                _buildStepIndicator(),
                const SizedBox(height: 32),

                // Content based on state
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.initial ||
                        state.status == AuthStatus.authenticated && state.mfaEnrollment == null) {
                      return _buildStartEnrollment();
                    } else if (state.status == AuthStatus.mfaEnrollment && state.mfaEnrollment != null) {
                      return _buildQrCodeStep(state.mfaEnrollment!);
                    } else if (state.status == AuthStatus.mfaChallenge && state.mfaChallenge != null) {
                      return _buildVerifyStep(state.mfaChallenge!.factorId);
                    }
                    return _buildStartEnrollment();
                  },
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        int currentStep = 1;
        if (state.status == AuthStatus.mfaEnrollment) currentStep = 2;
        if (state.status == AuthStatus.mfaChallenge) currentStep = 3;

        return Row(
          children: [
            _buildStep(1, 'Setup', currentStep >= 1),
            _buildStepConnector(currentStep >= 2),
            _buildStep(2, 'Scan QR', currentStep >= 2),
            _buildStepConnector(currentStep >= 3),
            _buildStep(3, 'Verify', currentStep >= 3),
          ],
        );
      },
    );
  }

  Widget _buildStep(int step, String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child: Center(
              child: active
                  ? Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.onPrimary)
                  : Text('$step', style: TextStyle(color: active ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 28),
        color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildStartEnrollment() {
    return Column(
      children: [
        Icon(
          Icons.security_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Add an extra layer of security',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Two-factor authentication (2FA) protects your account by requiring a code from your authenticator app in addition to your password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'ll need:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildRequirement('An authenticator app (Google Authenticator, Authy, 1Password, etc.)'),
              _buildRequirement('Your mobile device to scan the QR code'),
              _buildRequirement('Access to this device for future logins'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        FFTButton(
          text: 'Enable 2FA',
          onPressed: _onEnroll,
          size: ButtonSize.lg,
        ),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
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

  Widget _buildQrCodeStep(MfaEnrollResponse enrollment) {
    return Column(
      children: [
        Text(
          'Scan the QR code with your authenticator app',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Or enter this secret key manually:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // QR Code
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: QrImageView(
            data: enrollment.uri,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Secret key
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Secret Key',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_showSecret ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showSecret = !_showSecret),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                _showSecret ? enrollment.secret : '••••••••••••••••',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
                onPressed: () {
                  // Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Secret key copied')),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'After scanning, enter the 6-digit code from your app to verify',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        Form(
          key: _formKey,
          child: FFTTextField(
            controller: _codeController,
            label: '6-Digit Code',
            hint: '000000',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter the code from your authenticator app';
              }
              if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'Enter a valid 6-digit code';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),

        FFTButton(
          text: 'Verify & Enable',
          onPressed: _isLoading ? null : () {
            setState(() => _isLoading = true);
            _onChallengeAndVerify();
          },
          isLoading: _isLoading,
          size: ButtonSize.lg,
        ),
      ],
    );
  }

  Widget _buildVerifyStep(String factorId) {
    return Column(
      children: [
        Text(
          'Enter the code to verify',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code from your authenticator app',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        Form(
          key: _formKey,
          child: FFTTextField(
            controller: _codeController,
            label: '6-Digit Code',
            hint: '000000',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter the code from your authenticator app';
              }
              if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'Enter a valid 6-digit code';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),

        FFTButton(
          text: 'Verify',
          onPressed: _isLoading ? null : _onVerify,
          isLoading: _isLoading,
          size: ButtonSize.lg,
        ),
      ],
    );
  }
}
