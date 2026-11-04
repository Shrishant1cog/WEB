/// FFT Mobile Application Entry Point
/// Independent Free Fire India Tournament Management Platform

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client.dart';
import 'core/security/secure_storage.dart';
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
  HydratedBlocOverrides.runZoned(
    () async {
      // Initialize Supabase
      await SupabaseClientManager.initialize();

      // Initialize dependency injection
      await di.init();

      // Run app
      runApp(const FFTApp());
    },
    storage: storage,
  );
}

/// Root application widget
class FFTApp extends StatelessWidget {
  const FFTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add global BLoCs here (auth, theme, etc.)
        // BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: MaterialApp.router(
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
      ),
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // AppConfig is already validated in main()
      // Additional initialization can go here:
      // - Check for app updates
      // - Load feature flags
      // - Initialize analytics (if enabled)
      // - Check biometric availability
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to initialize app'),
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _initializeApp(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

    return widget.child;
  }
}