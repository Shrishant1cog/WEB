/// Dependency Injection Container
/// Uses GetIt for service location with Injectable for code generation

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/supabase_client.dart';
import 'core/security/secure_storage.dart';
import 'data/datasources/remote/team_remote_data_source.dart';
import 'data/datasources/remote/tournament_remote_data_source.dart';
import 'data/repositories/team_repository_impl.dart';
import 'data/repositories/tournament_repository_impl.dart';
import 'domain/repositories/team_repository.dart';
import 'domain/repositories/tournament_repository.dart';

final getIt = GetIt.instance;

/// Lazily resolve the Phase 3 repositories.
///
/// Accessing `SupabaseClientManager.client` through GetIt keeps the client
/// lazy, so importing these getters never initializes Supabase by itself.
TournamentRepository get tournamentRepository => getIt<TournamentRepository>();

TeamRepository get teamRepository => getIt<TeamRepository>();

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
}

void _registerCore() {
  // AppConfig is static, no registration needed

  // Supabase Client - only registered if initialized
  // DI is initialized after Supabase, so client should be available
  getIt.registerLazySingleton<SupabaseClient>(
    () => SupabaseClientManager.client ??
        (throw StateError('SupabaseClient not initialized. Ensure Supabase is configured and initialized before DI.')),
  );

  // Secure Storage
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage.create());
}

void _registerDataSources() {
  getIt.registerLazySingleton<TournamentRemoteDataSource>(
    () => TournamentRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<TeamRemoteDataSource>(
    () => TeamRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<TournamentRepository>(
    () => TournamentRepositoryImpl(getIt<TournamentRemoteDataSource>()),
  );
  getIt.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(getIt<TeamRemoteDataSource>()),
  );
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
  // In GetIt 9.x, isRegistered() doesn't take type parameters
  // We'll just check if the instances can be retrieved
  try {
    getIt<SupabaseClient>();
    getIt<SecureStorage>();
    return true;
  } catch (_) {
    return false;
  }
}