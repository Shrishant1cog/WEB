/// Reset Password Use Case
/// Handles password reset request

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String email,
  }) async {
    return _repository.resetPassword(email: email);
  }
}


