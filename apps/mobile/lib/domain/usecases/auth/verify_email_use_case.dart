/// Verify Email Use Case
/// Handles email verification resend

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String email,
  }) async {
    return _repository.resendVerificationEmail(email: email);
  }
}


