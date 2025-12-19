import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/local_database.dart';
import 'user_profile.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  // We throw here if accessed before ready, but the UI should handle loading state
  return OnboardingRepository(isarAsync.value!);
});

class OnboardingRepository {
  final Isar _isar;

  OnboardingRepository(this._isar);

  Future<void> saveUserProfile(UserProfile profile) async {
    await _isar.writeTxn(() async {
      await _isar.userProfiles.put(profile);
    });
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    return await _isar.userProfiles.filter().userIdEqualTo(userId).findFirst();
  }

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _isar.userProfiles.filter().userIdEqualTo(userId).watch(fireImmediately: true).map((events) => events.firstOrNull);
  }
}
