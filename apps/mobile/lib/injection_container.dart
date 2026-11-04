/// Dependency Injection Container
/// Uses GetIt for service location with Injectable for code generation

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/network/supabase_client.dart';
import 'core/security/secure_storage.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
/// Run this once at app startup before runApp()
Future<void> init() async {
  // Core
  _registerCore();

  // Data Sources
  _registerDataSources();

  // Repositories
  _registerRepositories();

  // Use Cases
  _registerUseCases();

  // BLoCs / Cubits
  _registerBlocs();

  // Initialize generated dependencies
  await getIt.init();
}

void _registerCore() {
  // AppConfig is static, no registration needed

  // Supabase Client
  getIt.registerLazySingleton<SupabaseClient>(() => SupabaseClientManager.client);

  // Secure Storage
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage.create());
}

void _registerDataSources() {
  // TODO: Register data sources when implemented
  // getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(getIt()));
  // getIt.registerLazySingleton<TournamentRemoteDataSource>(() => TournamentRemoteDataSourceImpl(getIt()));
  // getIt.registerLazySingleton<TeamRemoteDataSource>(() => TeamRemoteDataSourceImpl(getIt()));
  // getIt.registerLazySingleton<MatchRemoteDataSource>(() => MatchRemoteDataSourceImpl(getIt()));
  // getIt.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(getIt()));
  //
  // // Local data sources
  // getIt.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(getIt()));
  // getIt.registerLazySingleton<PreferencesLocalDataSource>(() => PreferencesLocalDataSourceImpl(getIt()));
}

void _registerRepositories() {
  // TODO: Register repositories when implemented
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt(), getIt()));
  // getIt.registerLazySingleton<TournamentRepository>(() => TournamentRepositoryImpl(getIt()));
  // getIt.registerLazySingleton<TeamRepository>(() => TeamRepositoryImpl(getIt(), getIt()));
  // getIt.registerLazySingleton<MatchRepository>(() => MatchRepositoryImpl(getIt()));
  // getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(getIt(), getIt()));
}

void _registerUseCases() {
  // TODO: Register use cases when implemented
  // Auth
  // getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  // getIt.registerLazySingleton(() => SignUpUseCase(getIt()));
  // getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  // getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt()));
  // getIt.registerLazySingleton(() => VerifyEmailUseCase(getIt()));
  // getIt.registerLazySingleton(() => DeleteAccountUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  //
  // Profile
  // getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));
  // getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  // getIt.registerLazySingleton(() => UpdatePrivacySettingsUseCase(getIt()));
  //
  // Tournaments
  // getIt.registerLazySingleton(() => GetTournamentsUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetTournamentDetailUseCase(getIt()));
  // getIt.registerLazySingleton(() => RegisterForTournamentUseCase(getIt()));
  // getIt.registerLazySingleton(() => WithdrawFromTournamentUseCase(getIt()));
  //
  // Teams
  // getIt.registerLazySingleton(() => CreateTeamUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetTeamUseCase(getIt()));
  // getIt.registerLazySingleton(() => InviteToTeamUseCase(getIt()));
  // getIt.registerLazySingleton(() => AcceptTeamInvitationUseCase(getIt()));
  // getIt.registerLazySingleton(() => LeaveTeamUseCase(getIt()));
  // getIt.registerLazySingleton(() => RegisterTeamForTournamentUseCase(getIt()));
  //
  // Matches
  // getIt.registerLazySingleton(() => GetMatchesUseCase(getIt()));
  // getIt.registerLazySingleton(() => GetMatchCredentialsUseCase(getIt()));
  //
  // Results & Disputes
  // getIt.registerLazySingleton(() => GetResultsUseCase(getIt()));
  // getIt.registerLazySingleton(() => SubmitDisputeUseCase(getIt()));
  //
  // Notifications
  // getIt.registerLazySingleton(() => GetNotificationsUseCase(getIt()));
  // getIt.registerLazySingleton(() => MarkNotificationReadUseCase(getIt()));
  // getIt.registerLazySingleton(() => UpdateNotificationPreferencesUseCase(getIt()));
}

void _registerBlocs() {
  // TODO: Register BLoCs when implemented
  // getIt.registerFactory(() => AuthBloc(
  //   signInUseCase: getIt(),
  //   signUpUseCase: getIt(),
  //   signOutUseCase: getIt(),
  //   resetPasswordUseCase: getIt(),
  //   verifyEmailUseCase: getIt(),
  //   deleteAccountUseCase: getIt(),
  //   getCurrentUserUseCase: getIt(),
  // ));
  //
  // getIt.registerFactory(() => TournamentBloc(
  //   getTournamentsUseCase: getIt(),
  //   getTournamentDetailUseCase: getIt(),
  //   registerForTournamentUseCase: getIt(),
  //   withdrawFromTournamentUseCase: getIt(),
  // ));
  //
  // getIt.registerFactory(() => TeamBloc(
  //   createTeamUseCase: getIt(),
  //   getTeamUseCase: getIt(),
  //   inviteToTeamUseCase: getIt(),
  //   acceptTeamInvitationUseCase: getIt(),
  //   leaveTeamUseCase: getIt(),
  //   registerTeamForTournamentUseCase: getIt(),
  // ));
  //
  // getIt.registerFactory(() => ProfileBloc(
  //   getProfileUseCase: getIt(),
  //   updateProfileUseCase: getIt(),
  //   updatePrivacySettingsUseCase: getIt(),
  // ));
  //
  // getIt.registerFactory(() => MatchBloc(
  //   getMatchesUseCase: getIt(),
  //   getMatchCredentialsUseCase: getIt(),
  // ));
  //
  // getIt.registerFactory(() => ResultBloc(
  //   getResultsUseCase: getIt(),
  //   submitDisputeUseCase: getIt(),
  // ));
  //
  // getIt.registerFactory(() => NotificationBloc(
  //   getNotificationsUseCase: getIt(),
  //   markNotificationReadUseCase: getIt(),
  //   updateNotificationPreferencesUseCase: getIt(),
  // ));
}

/// Reset dependencies (for testing)
Future<void> reset() async {
  await getIt.reset();
}

/// Check if all required dependencies are registered
bool validate() {
  final required = [
    SupabaseClient,
    SecureStorage,
  ];

  for (final type in required) {
    if (!getIt.isRegistered(type)) {
      return false;
    }
  }
  return true;
}