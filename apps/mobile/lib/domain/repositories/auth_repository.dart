/// Domain repository interface for authentication
/// Defines the contract for authentication operations

import 'package:dartz/dartz.dart';

import '../../data/models/auth_models.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Sign up a new user with email and password
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  });

  /// Sign in with email and password
  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<Either<Failure, Unit>> signOut();

  /// Request password reset email
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  });

  /// Update user password (requires authenticated session)
  Future<Either<Failure, Unit>> updatePassword({
    required String password,
  });

  /// Update user email (requires confirmation)
  Future<Either<Failure, Unit>> updateEmail({
    required String email,
  });

  /// Get current authenticated user
  Future<Either<Failure, AuthResponse>> getCurrentUser();

  /// Resend email verification
  Future<Either<Failure, Unit>> resendVerificationEmail({
    required String email,
  });

  /// Enroll TOTP MFA factor
  Future<Either<Failure, MfaEnrollResponse>> enrollMfaTotp();

  /// Challenge TOTP MFA factor
  Future<Either<Failure, MfaChallengeResponse>> challengeMfaTotp({
    required String factorId,
  });

  /// Verify TOTP MFA code
  Future<Either<Failure, MfaVerifyResponse>> verifyMfaTotp({
    required String factorId,
    required String challengeId,
    required String code,
  });

  /// List enrolled MFA factors
  Future<Either<Failure, List<MfaFactorModel>>> listMfaFactors();

  /// Unenroll MFA factor
  Future<Either<Failure, Unit>> unenrollMfaFactor({
    required String factorId,
  });

  /// Delete user account (requires reauthentication)
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
  });
}