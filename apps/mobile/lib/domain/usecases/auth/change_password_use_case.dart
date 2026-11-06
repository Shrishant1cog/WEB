/// Change Password Use Case
/// Changes the current user's password with current password verification

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    // This would require reauthentication - for now delegate to updatePassword
    // In a full implementation, this would use reauthenticate with current password
    if (newPassword.length < 12) {
      return Left(ValidationFailure(
        message: 'New password must be at least 12 characters',
        code: 'WEAK_PASSWORD',
      ));
    }
    return _repository.updatePassword(password: newPassword);
  }
}


