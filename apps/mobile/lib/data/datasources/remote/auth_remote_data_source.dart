/// Remote data source for authentication operations
/// Uses Supabase Flutter SDK directly

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthResponse;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../data/models/auth_models.dart';
import '../../../core/errors/failures.dart';

@injectable
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'terms_accepted': termsAccepted,
          'age_attestation': ageAttestation,
        },
      );

      if (response.user == null) {
        return Left(ServerFailure(
          message: 'Signup failed: no user returned',
          code: 'SIGNUP_FAILED',
        ));
      }

      return Right(AuthResponse(
        userId: response.user!.id,
        email: response.user!.email,
        accessToken: response.session?.accessToken,
        refreshToken: response.session?.refreshToken,
        emailVerified: response.user!.emailConfirmedAt != null,
        message: response.user!.emailConfirmedAt == null
            ? 'Please check your email to verify your account'
            : 'Account created successfully',
      ));
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Signup failed: ${e.toString()}',
        code: 'SIGNUP_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        return Left(AuthFailure(
          message: 'Invalid credentials',
          code: 'INVALID_CREDENTIALS',
        ));
      }

      return Right(AuthResponse(
        userId: response.user!.id,
        email: response.user!.email,
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken,
        emailVerified: response.user!.emailConfirmedAt != null,
      ));
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Sign in failed: ${e.toString()}',
        code: 'SIGNIN_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _client.auth.signOut();
      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Sign out failed: ${e.toString()}',
        code: 'SIGNOUT_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Password reset request failed: ${e.toString()}',
        code: 'RESET_PASSWORD_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required String password,
  }) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Password update failed: ${e.toString()}',
        code: 'UPDATE_PASSWORD_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateEmail({
    required String email,
  }) async {
    try {
      await _client.auth.updateUser(UserAttributes(email: email));
      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Email update failed: ${e.toString()}',
        code: 'UPDATE_EMAIL_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      final session = _client.auth.currentSession;

      if (user == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      return Right(AuthResponse(
        userId: user.id,
        email: user.email,
        accessToken: session?.accessToken,
        refreshToken: session?.refreshToken,
        emailVerified: user.emailConfirmedAt != null,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to get current user: ${e.toString()}',
        code: 'GET_USER_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendVerificationEmail({
    required String email,
  }) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to resend verification: ${e.toString()}',
        code: 'RESEND_VERIFICATION_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, MfaEnrollResponse>> enrollMfaTotp() async {
    try {
      final response = await _client.auth.mfa.enroll(
        factorType: FactorType.totp,
        friendlyName: 'Authenticator App',
      );

      return Right(MfaEnrollResponse(
        factorId: response.id,
        qrCode: response.totp!.qrCode,
        secret: response.totp!.secret,
        uri: response.totp!.uri,
      ));
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'MFA enrollment failed: ${e.toString()}',
        code: 'MFA_ENROLL_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, MfaChallengeResponse>> challengeMfaTotp({
    required String factorId,
  }) async {
    try {
      final response = await _client.auth.mfa.challenge(
        factorId: factorId,
      );

      return Right(MfaChallengeResponse(
        factorId: factorId,
        challengeId: response.id,
      ));
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'MFA challenge failed: ${e.toString()}',
        code: 'MFA_CHALLENGE_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, MfaVerifyResponse>> verifyMfaTotp({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    try {
      final response = await _client.auth.mfa.verify(
        factorId: factorId,
        challengeId: challengeId,
        code: code,
      );

      return Right(MfaVerifyResponse(
        verified: true,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ));
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'MFA verification failed: ${e.toString()}',
        code: 'MFA_VERIFY_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<MfaFactorModel>>> listMfaFactors() async {
    try {
      final factors = await _client.auth.mfa.listFactors();

      return Right(factors.all.map((f) => MfaFactorModel(
        id: f.id,
        factorType: f.factorType.name,
        status: f.status.name,
        createdAt: f.createdAt.toIso8601String(),
        updatedAt: f.updatedAt.toIso8601String(),
      )).toList());
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to list MFA factors: ${e.toString()}',
        code: 'LIST_MFA_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> unenrollMfaFactor({
    required String factorId,
  }) async {
    try {
      await _client.auth.mfa.unenroll(factorId);
      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'MFA unenrollment failed: ${e.toString()}',
        code: 'MFA_UNENROLL_ERROR',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
  }) async {
    try {
      // Re-authenticate with password before deletion
      final user = _client.auth.currentUser;
      if (user == null || user.email == null) {
        return Left(AuthFailure(
          message: 'No authenticated user',
          code: 'NO_USER',
        ));
      }

      // Sign in with password to get fresh session
      await _client.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      // Delete the user
      await _client.auth.admin.deleteUser(user.id);

      return Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Account deletion failed: ${e.toString()}',
        code: 'DELETE_ACCOUNT_ERROR',
        originalError: e,
      ));
    }
  }

  Failure _mapAuthException(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
      case 'Invalid email or password':
        return AuthFailure(
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS',
          originalError: e,
        );
      case 'Email not confirmed':
        return AuthFailure(
          message: 'Please verify your email before signing in',
          code: 'EMAIL_NOT_VERIFIED',
          originalError: e,
        );
      case 'User already registered':
        return AuthFailure(
          message: 'An account with this email already exists',
          code: 'EMAIL_EXISTS',
          originalError: e,
        );
      case 'Weak password':
        return ValidationFailure(
          message: 'Password is too weak',
          code: 'WEAK_PASSWORD',
          originalError: e,
        );
      case 'Invalid email':
        return ValidationFailure(
          message: 'Please enter a valid email address',
          code: 'INVALID_EMAIL',
          originalError: e,
        );
      case 'Too many requests':
        return ServerFailure(
          message: 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          originalError: e,
        );
      default:
        return AuthFailure(
          message: e.message,
          code: 'AUTH_ERROR',
          originalError: e,
        );
    }
  }
}

abstract class AuthRemoteDataSource {
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  });

  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  });

  Future<Either<Failure, Unit>> updatePassword({
    required String password,
  });

  Future<Either<Failure, Unit>> updateEmail({
    required String email,
  });

  Future<Either<Failure, AuthResponse>> getCurrentUser();

  Future<Either<Failure, Unit>> resendVerificationEmail({
    required String email,
  });

  Future<Either<Failure, MfaEnrollResponse>> enrollMfaTotp();

  Future<Either<Failure, MfaChallengeResponse>> challengeMfaTotp({
    required String factorId,
  });

  Future<Either<Failure, MfaVerifyResponse>> verifyMfaTotp({
    required String factorId,
    required String challengeId,
    required String code,
  });

  Future<Either<Failure, List<MfaFactorModel>>> listMfaFactors();

  Future<Either<Failure, Unit>> unenrollMfaFactor({
    required String factorId,
  });

  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
  });
}