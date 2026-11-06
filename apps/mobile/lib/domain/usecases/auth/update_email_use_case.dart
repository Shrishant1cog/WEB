/// Update Email Use Case
/// Updates the current user's email address

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class UpdateEmailUseCase {
  final AuthRepository _repository;

  UpdateEmailUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String email,
  }) async {
    return _repository.updateEmail(email: email);
  }
}


