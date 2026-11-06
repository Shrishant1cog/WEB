/// Sign Up Use Case
/// Handles user registration with email and password

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../../../data/models/auth_models.dart';

@injectable
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
    required String displayName,
    required bool termsAccepted,
    required bool ageAttestation,
  }) async {
    return _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
      termsAccepted: termsAccepted,
      ageAttestation: ageAttestation,
    );
  }
}


