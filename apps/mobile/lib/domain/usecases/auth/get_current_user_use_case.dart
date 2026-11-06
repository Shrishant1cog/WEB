/// Get Current User Use Case
/// Retrieves the current authenticated user

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '\.\./\.\./\.\./data/models/auth_models.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call() async {
    return _repository.getCurrentUser();
  }
}


