/// Unenroll MFA Factor Use Case
/// Removes an enrolled MFA factor

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class UnenrollMfaFactorUseCase {
  final AuthRepository _repository;

  UnenrollMfaFactorUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String factorId,
  }) async {
    return _repository.unenrollMfaFactor(factorId: factorId);
  }
}


