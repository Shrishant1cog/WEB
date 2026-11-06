/// Update Password Use Case
/// Updates the current user's password

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class UpdatePasswordUseCase {
  final AuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String password,
  }) async {
    return _repository.updatePassword(password: password);
  }
}


