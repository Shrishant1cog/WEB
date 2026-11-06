/// Register Page
/// Email/password registration with terms and age attestation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/utils/validators.dart';
import '../../../../../../presentation/shared/widgets/fft_button.dart';
import '../../../../../../presentation/shared/widgets/fft_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  bool _ageAttested = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _displayNameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() {});
      return;
    }
    if (!_ageAttested) {
      setState(() {});
      return;
    }

    context.read<AuthBloc>().add(AuthSignUpRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
      termsAccepted: _termsAccepted,
      ageAttestation: _ageAttested,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/profile');
        } else if (state.status == AuthStatus.verificationPending) {
          context.go('/email-verify');
        } else if (state.status == AuthStatus.failure && state.error != null) {
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
          title: const Text('Create Account'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Create your FFT account',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join tournaments, manage teams, and compete',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FFTTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.validateEmail,
                    onChanged: (value) => setState(() => _emailError = null),
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 16),
                  FFTTextField(
                    controller: _displayNameController,
                    label: 'Display Name',
                    hint: 'Your tournament name',
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.validateDisplayName,
                    onChanged: (value) => setState(() => _displayNameError = null),
                    errorText: _displayNameError,
                  ),
                  const SizedBox(height: 16),
                  FFTTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'At least 12 characters',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: Validators.validatePassword,
                    onChanged: (value) => setState(() => _passwordError = null),
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 16),
                  FFTTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() => _confirmPasswordError = null),
                    errorText: _confirmPasswordError,
                    onFieldSubmitted: (_) => _onSubmit(),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(
                      'I accept the Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _termsAccepted,
                    onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  CheckboxListTile(
                    title: Text(
                      'I am 18 years or older (closed pilot requires 18+)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _ageAttested,
                    onChanged: (value) => setState(() => _ageAttested = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return FFTButton(
                        text: 'Create Account',
                        onPressed: state.status == AuthStatus.loading ? null : _onSubmit,
                        isLoading: state.status == AuthStatus.loading,
                        size: ButtonSize.lg,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'FFT is an independent tournament management platform.\nIt is not affiliated with, endorsed by, or operated by Garena.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


