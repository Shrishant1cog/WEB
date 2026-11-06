/// Get Profile Use Case
/// Retrieves the current user's profile

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/profile_repository.dart';
import '\.\./\.\./\.\./data/models/profile_models.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, Profile>> call() async {
    return _repository.getProfile();
  }
}

