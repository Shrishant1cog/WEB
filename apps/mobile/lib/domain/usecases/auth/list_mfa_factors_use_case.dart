/// List MFA Factors Use Case
/// Lists all enrolled MFA factors for the current user

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '\.\./\.\./\.\./data/models/auth_models.dart';

@injectable
class ListMfaFactorsUseCase {
  final AuthRepository _repository;

  ListMfaFactorsUseCase(this._repository);

  Future<Either<Failure, List<MfaFactorModel>>> call() async {
    return _repository.listMfaFactors();
  }
}


