/// Sign In Use Case
/// Handles user authentication with email and password

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '\.\./\.\./\.\./data/models/auth_models.dart';

@injectable
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
  }) async {
    return _repository.signIn(
      email: email,
      password: password,
    );
  }
}


