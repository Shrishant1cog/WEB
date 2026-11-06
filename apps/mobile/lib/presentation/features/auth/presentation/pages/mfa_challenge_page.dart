/// MFA Challenge Page
/// Verify TOTP code during sign-in

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../presentation/shared/widgets/fft_button.dart';
import '../../../../../../presentation/shared/widgets/fft_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class MfaChallengePage extends StatefulWidget {
  final String? factorId;
  const MfaChallengePage({super.key, this.factorId});

  @override
  State<MfaChallengePage> createState() => _MfaChallengePageState();
}

class _MfaChallengePageState extends State<MfaChallengePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _factorId;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use factorId from widget or from extra
    String? factorId = widget.factorId;
    if (factorId == null) {
      final args = GoRouterState.of(context).extra;
      if (args is String) {
        factorId = args;
      }
    }

    if (factorId != null) {
      // Initiate challenge when page loads
      context.read<AuthBloc>().add(AuthChallengeMfaTotpRequested(
        factorId: factorId,
      ));
    }
  }

  void _onVerify() {
    if (!_formKey.currentState!.validate()) return;
    if (_factorId == null) return;

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(AuthVerifyMfaTotpRequested(
      factorId: _factorId!,
      challengeId: '', // Will be filled by challenge step
      code: _codeController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.mfaChallenge() && state.mfaChallenge != null) {
          // Challenge created, now verify
          context.read<AuthBloc>().add(AuthVerifyMfaTotpRequested(
            factorId: state.mfaChallenge!.factorId,
            challengeId: state.mfaChallenge!.challengeId,
            code: _codeController.text.trim(),
          ));
        } else if (state.status == AuthStatus.authenticated() && state.aalLevel == 'aal2') {
          // MFA verified successfully
          context.go('/my-tournaments');
        } else if (state.status == AuthStatus.failure() && state.error != null) {
          setState(() {
            _isLoading = false;
            _error = state.error;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Two-Factor Authentication'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.security_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter your 2FA code',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Open your authenticator app and enter the 6-digit code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

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

                Form(
                  key: _formKey,
                  child: FFTTextField(
                    controller: _codeController,
                    label: '6-Digit Code',
                    hint: '000000',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock_outlined,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter the code from your authenticator app';
                      }
                      if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Enter a valid 6-digit code';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _onVerify(),
                  ),
                ),

                const SizedBox(height: 24),

                FFTButton(
                  text: 'Verify',
                  onPressed: _isLoading ? null : _onVerify,
                  isLoading: _isLoading,
                  size: ButtonSize.lg,
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    // Use backup codes or alternative method
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backup codes not implemented yet. Contact support if you lost access to your authenticator app.'),
                      ),
                    );
                  },
                  child: const Text('Lost access to authenticator?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}