/// Delete Account Use Case
/// Handles account deletion with reauthentication

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

@injectable
class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String password,
  }) async {
    return _repository.deleteAccount(password: password);
  }
}


