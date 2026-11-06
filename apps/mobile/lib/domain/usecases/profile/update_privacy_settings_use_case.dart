/// Update Privacy Settings Use Case
/// Updates user privacy settings

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/profile_models.dart';
import '../../repositories/profile_repository.dart';

@injectable
class UpdatePrivacySettingsUseCase {
  final ProfileRepository _repository;

  UpdatePrivacySettingsUseCase(this._repository);

  Future<Either<Failure, Profile>> call({
    required String profileVisibility,
    required bool showInGameInfo,
  }) async {
    const validVisibilities = ['public', 'organizers_only', 'private'];
    if (!validVisibilities.contains(profileVisibility)) {
      return Left(ValidationFailure(
        message: 'Invalid profile visibility',
        code: 'INVALID_VISIBILITY',
      ));
    }

    return _repository.updatePrivacySettings(
      profileVisibility: profileVisibility,
      showInGameInfo: showInGameInfo,
    );
  }
}

