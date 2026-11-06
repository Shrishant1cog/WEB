/// Enroll MFA TOTP Use Case
/// Handles TOTP MFA enrollment

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '\.\./\.\./\.\./data/models/auth_models.dart';

@injectable
class EnrollMfaTotpUseCase {
  final AuthRepository _repository;

  EnrollMfaTotpUseCase(this._repository);

  Future<Either<Failure, MfaEnrollResponse>> call() async {
    return _repository.enrollMfaTotp();
  }
}


