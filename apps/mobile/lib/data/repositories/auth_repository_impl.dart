/// Repository implementation for authentication
/// Coordinates between data sources and domain layer

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';

@injectable
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  }) async {
    // Validate input
    if (email.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        code: 'EMPTY_EMAIL',
      ));
    }
    if (password.length < 12) {
      return Left(ValidationFailure(
        message: 'Password must be at least 12 characters',
        code: 'WEAK_PASSWORD',
      ));
    }
    if (displayName.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Display name is required',
        code: 'EMPTY_DISPLAY_NAME',
      ));
    }
    if (!termsAccepted) {
      return Left(ValidationFailure(
        message: 'You must accept the terms and privacy policy',
        code: 'TERMS_NOT_ACCEPTED',
      ));
    }
    if (!ageAttestation) {
      return Left(ValidationFailure(
        message: 'You must confirm you are 18 or older',
        code: 'AGE_NOT_ATTESTED',
      ));
    }

    return _remoteDataSource.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName.trim(),
      termsAccepted: termsAccepted,
      ageAttestation: ageAttestation,
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        code: 'EMPTY_EMAIL',
      ));
    }
    if (password.isEmpty) {
      return Left(ValidationFailure(
        message: 'Password is required',
        code: 'EMPTY_PASSWORD',
      ));
    }

    return _remoteDataSource.signIn(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return _remoteDataSource.signOut();
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        code: 'EMPTY_EMAIL',
      ));
    }

    return _remoteDataSource.resetPassword(email: email.trim().toLowerCase());
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required String password,
  }) async {
    if (password.length < 12) {
      return Left(ValidationFailure(
        message: 'Password must be at least 12 characters',
        code: 'WEAK_PASSWORD',
      ));
    }

    return _remoteDataSource.updatePassword(password: password);
  }

  @override
  Future<Either<Failure, Unit>> updateEmail({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        code: 'EMPTY_EMAIL',
      ));
    }

    return _remoteDataSource.updateEmail(email: email.trim().toLowerCase());
  }

  @override
  Future<Either<Failure, AuthResponse>> getCurrentUser() async {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, Unit>> resendVerificationEmail({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Email is required',
        code: 'EMPTY_EMAIL',
      ));
    }

    return _remoteDataSource.resendVerificationEmail(email: email.trim().toLowerCase());
  }

  @override
  Future<Either<Failure, MfaEnrollResponse>> enrollMfaTotp() async {
    return _remoteDataSource.enrollMfaTotp();
  }

  @override
  Future<Either<Failure, MfaChallengeResponse>> challengeMfaTotp({
    required String factorId,
  }) async {
    if (factorId.isEmpty) {
      return Left(ValidationFailure(
        message: 'Factor ID is required',
        code: 'EMPTY_FACTOR_ID',
      ));
    }

    return _remoteDataSource.challengeMfaTotp(factorId: factorId);
  }

  @override
  Future<Either<Failure, MfaVerifyResponse>> verifyMfaTotp({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    if (factorId.isEmpty) {
      return Left(ValidationFailure(
        message: 'Factor ID is required',
        code: 'EMPTY_FACTOR_ID',
      ));
    }
    if (challengeId.isEmpty) {
      return Left(ValidationFailure(
        message: 'Challenge ID is required',
        code: 'EMPTY_CHALLENGE_ID',
      ));
    }
    if (code.isEmpty || code.length != 6) {
      return Left(ValidationFailure(
        message: 'Enter a valid 6-digit code',
        code: 'INVALID_CODE',
      ));
    }

    return _remoteDataSource.verifyMfaTotp(
      factorId: factorId,
      challengeId: challengeId,
      code: code,
    );
  }

  @override
  Future<Either<Failure, List<MfaFactorModel>>> listMfaFactors() async {
    return _remoteDataSource.listMfaFactors();
  }

  @override
  Future<Either<Failure, Unit>> unenrollMfaFactor({
    required String factorId,
  }) async {
    if (factorId.isEmpty) {
      return Left(ValidationFailure(
        message: 'Factor ID is required',
        code: 'EMPTY_FACTOR_ID',
      ));
    }

    return _remoteDataSource.unenrollMfaFactor(factorId: factorId);
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
  }) async {
    if (password.isEmpty) {
      return Left(ValidationFailure(
        message: 'Password is required to confirm deletion',
        code: 'EMPTY_PASSWORD',
      ));
    }

    return _remoteDataSource.deleteAccount(password: password);
  }
}