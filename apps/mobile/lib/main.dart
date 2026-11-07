/// FFT Mobile Application Entry Point
/// Independent Free Fire India Tournament Management Platform

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_links/app_links.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client.dart';
import 'presentation/shared/themes/app_theme.dart';
import 'presentation/shared/navigation/app_router.dart';
import 'injection_container.dart' as di;

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc storage for state persistence
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;

  // Run app with initializer wrapper
  runApp(const AppInitializer(child: FFTApp()));
}

/// Root application widget
class FFTApp extends StatelessWidget {
  const FFTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider requires at least one provider
    // For now, we don't have any global BLoCs, so use MaterialApp.router directly
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system preference
      routerConfig: AppRouter.router,
      // Localization
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
      ],
      localizationsDelegates: const [
        // Add localization delegates here
      ],
    );
  }
}

/// App initialization wrapper for splash screen / loading
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;
  String? _error;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Supabase (graceful - returns result instead of throwing)
      final supabaseResult = await SupabaseClientManager.initialize();
      if (supabaseResult.isFailure) {
        // Supabase not configured - this is OK for development
        // App will show configuration error screen with retry
        debugPrint('Supabase initialization failed: ${supabaseResult.error}');
        // Don't set error here - let the app start and show config screen
      }

      // Initialize dependency injection (only if Supabase is available)
      if (SupabaseClientManager.isInitialized) {
        await di.init();
      }

      // Set up deep link listener for auth callbacks (email verification, password reset)
      if (SupabaseClientManager.isInitialized) {
        _setupDeepLinkListener();
      }

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to initialize app: $e');
      }
    }
  }

  void _setupDeepLinkListener() {
    final appLinks = AppLinks();
    
    // Handle initial link (cold start)
    appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null && mounted) {
        _handleDeepLink(uri);
      }
    });

    // Handle subsequent links (app running in background/foreground)
    _linkSubscription = appLinks.uriLinkStream.listen((Uri uri) {
      if (mounted) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    // Check if this is an auth callback
    if (uri.path == '/auth/callback' || uri.queryParameters.containsKey('token')) {
      final token = uri.toString();
      final type = uri.queryParameters['type'] ?? 'signup';

      // Navigate to auth callback page which will process the token
      // Use go_router's GoRouter instance directly
      AppRouter.router.go('/auth/callback', extra: {'token': token, 'type': type});
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error screen if initialization threw an exception
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to initialize app', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _initializeApp(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show loading screen while initializing
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Initializing ${AppConfig.appName}...'),
              ],
            ),
          ),
        ),
      );
    }

    // Check if Supabase is configured
    if (!SupabaseClientManager.isConfigured) {
      return MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: _SupabaseConfigScreen(
          onRetry: _initializeApp,
        ),
      );
    }

    // Supabase configured but initialization failed
    if (!SupabaseClientManager.isInitialized) {
      final error = SupabaseClientManager.lastInitResult?.error ?? 'Unknown error';
      return MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Supabase Connection Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(error, style: const TextStyle(color: Colors.orange), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _initializeApp(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Everything initialized successfully
    return widget.child;
  }
}

/// Supabase configuration screen shown when credentials are not provided
class _SupabaseConfigScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _SupabaseConfigScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_queue_outlined,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Supabase Not Configured',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'The app requires Supabase credentials to connect to the backend.\n\n'
                  'Please provide the following via \`--dart-define\` at build time:\n\n'
                  '• SUPABASE_URL (your Supabase project URL)\n'
                  '• SUPABASE_ANON_KEY (your Supabase anon/public key)\n\n'
                  'Example:\n'
                  '\`flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co '
                  '--dart-define=SUPABASE_ANON_KEY=your-anon-key\`',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (AppConfig.isDebug) ...[
                  Text(
                    'Debug mode: Using local Supabase defaults\n'
                    'URL: ${AppConfig.supabaseUrl}\n'
                    'Anon Key: ${AppConfig.supabaseAnonKey.isEmpty ? "(empty)" : "(set)"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Initialization'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Show the app in demo/offline mode
                    // This would require a separate route setup
                  },
                  child: const Text('Continue Offline (Limited Features)'),
                ),
                const SizedBox(height: 32),
                Text(
                  'FFT v${AppConfig.appName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}