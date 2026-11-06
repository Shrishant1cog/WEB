/// Challenge MFA TOTP Use Case
/// Initiates TOTP challenge for MFA verification

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '\.\./\.\./\.\./data/models/auth_models.dart';

@injectable
class ChallengeMfaTotpUseCase {
  final AuthRepository _repository;

  ChallengeMfaTotpUseCase(this._repository);

  Future<Either<Failure, MfaChallengeResponse>> call({
    required String factorId,
  }) async {
    return _repository.challengeMfaTotp(factorId: factorId);
  }
}


