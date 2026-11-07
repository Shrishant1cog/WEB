/// Profile Edit Page
/// Edit profile information including avatar

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../../../presentation/shared/widgets/fft_button.dart';
import '../../../../../../presentation/shared/widgets/fft_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _inGameNameController = TextEditingController();
  final _inGameUidController = TextEditingController();
  File? _selectedImage;
  String? _avatarUrl;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String? _error;
  String? _usernameError;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final state = context.read<AuthBloc>().state;
    final profile = state.profile;
    if (profile != null) {
      setState(() {
        _displayNameController.text = profile.displayName;
        _usernameController.text = profile.username ?? '';
        _inGameNameController.text = profile.inGameName ?? '';
        _inGameUidController.text = profile.inGameUid ?? '';
        _avatarUrl = profile.avatarUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadAvatar();
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _removeAvatar() async {
    try {
      setState(() => _isUploadingAvatar = true);

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) return;

      // Delete from storage
      if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
        await client.storage.from('avatars').remove([_avatarUrl!]);
      }

      // Update profile
      await client.from('profiles').update({'avatar_url': null}).eq('id', user.id);

      setState(() {
        _avatarUrl = null;
        _selectedImage = null;
      });

      // Reload profile
      context.read<AuthBloc>().add(AuthLoadProfile());
    } catch (e) {
      setState(() => _error = 'Failed to remove avatar: ${e.toString()}');
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    try {
      setState(() => _isUploadingAvatar = true);

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) return;

      // Upload to Edge Function
      final response = await client.functions.invoke(
        'upload-avatar',
        body: {
          'file': _selectedImage!.path,
        },
      );

      if (response.data != null && response.data['avatarUrl'] != null) {
        setState(() {
          _avatarUrl = response.data['avatarUrl'] as String;
        });

        // Update profile in database
        await client.from('profiles').update({
          'avatar_url': _avatarUrl,
        }).eq('id', user.id);

        // Reload profile
        context.read<AuthBloc>().add(AuthLoadProfile());
      } else {
        throw Exception('Upload failed: ${response.data?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      setState(() => _error = 'Failed to upload avatar: ${e.toString()}');
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _usernameError = null);
      return;
    }

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (response != null) {
        setState(() => _usernameError = 'This username is already taken');
      } else {
        setState(() => _usernameError = null);
      }
    } catch (e) {
      setState(() => _usernameError = 'Failed to check username');
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_usernameError != null) return;

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(AuthUpdateProfileRequested(
      displayName: _displayNameController.text.trim(),
      username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      inGameName: _inGameNameController.text.trim().isEmpty ? null : _inGameNameController.text.trim(),
      inGameUid: _inGameUidController.text.trim().isEmpty ? null : _inGameUidController.text.trim(),
      avatarUrl: _avatarUrl,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.profile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.pop();
        } else if (state.status == AuthStatus.failure && state.error != null) {
          setState(() {
            _isLoading = false;
            _error = state.error;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : _avatarUrl != null
                                  ? NetworkImage(_avatarUrl!) as ImageProvider
                                  : null,
                          child: _selectedImage == null && _avatarUrl == null
                              ? Text(
                                  _displayNameController.text.isNotEmpty
                                      ? _displayNameController.text[0].toUpperCase()
                                      : '?',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 3,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _avatarUrl != null ? Icons.delete : Icons.camera_alt,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 20,
                              ),
                              onPressed: _isUploadingAvatar
                                  ? null
                                  : (_avatarUrl != null ? _removeAvatar : _pickImage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _avatarUrl != null ? 'Tap to change avatar' : 'Add an avatar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_isUploadingAvatar)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Display Name
                  FFTTextField(
                    controller: _displayNameController,
                    label: 'Display Name',
                    hint: 'Your display name',
                    prefixIcon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Display name is required';
                      }
                      if (value.trim().length < 1 || value.trim().length > 50) {
                        return 'Display name must be 1-50 characters';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // Username
                  FFTTextField(
                    controller: _usernameController,
                    label: 'Username (Optional)',
                    hint: 'Unique username (3-20 chars, alphanumeric + underscore)',
                    prefixIcon: Icons.alternate_email,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length < 3 || value.trim().length > 20) {
                          return 'Username must be 3-20 characters';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                          return 'Username can only contain letters, numbers, and underscore';
                        }
                      }
                      return _usernameError;
                    },
                    onChanged: (value) {
                      _checkUsernameAvailability();
                    },
                  ),

                  if (_usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        _usernameError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // In-Game Name
                  FFTTextField(
                    controller: _inGameNameController,
                    label: 'In-Game Name (Optional)',
                    hint: 'Your Free Fire in-game name',
                    prefixIcon: Icons.sports_esports,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty && value.trim().length > 30) {
                        return 'In-game name must be 30 characters or less';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // In-Game UID
                  FFTTextField(
                    controller: _inGameUidController,
                    label: 'In-Game UID (Optional)',
                    hint: 'Your Free Fire UID (8-12 digits)',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!RegExp(r'^\d{8,12}$').hasMatch(value.trim())) {
                          return 'UID must be 8-12 digits';
                        }
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
                    text: 'Save Changes',
                    onPressed: _isLoading ? null : _onSubmit,
                    isLoading: _isLoading,
                    size: ButtonSize.lg,
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
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
