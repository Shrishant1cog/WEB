/// Verify MFA TOTP Use Case
/// Verifies TOTP code for MFA verification

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '\.\./\.\./\.\./data/models/auth_models.dart';

@injectable
class VerifyMfaTotpUseCase {
  final AuthRepository _repository;

  VerifyMfaTotpUseCase(this._repository);

  Future<Either<Failure, MfaVerifyResponse>> call({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    return _repository.verifyMfaTotp(
      factorId: factorId,
      challengeId: challengeId,
      code: code,
    );
  }
}


