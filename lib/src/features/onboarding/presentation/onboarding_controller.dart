import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import '../../auth/data/auth_repository.dart';
import '../data/onboarding_repository.dart';
import '../data/user_profile.dart';

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, AsyncValue<void>>((ref) {
  final isarAsync = ref.watch(isarProvider);
  if (isarAsync.asData?.value == null) {
     return OnboardingController(null, null); 
  }
  final repo = OnboardingRepository(isarAsync.value!);
  final authRepo = ref.watch(authRepositoryProvider);
  return OnboardingController(repo, authRepo);
});

class OnboardingController extends StateNotifier<AsyncValue<void>> {
  final OnboardingRepository? _repository;
  final AuthRepository? _authRepository;

  OnboardingController(this._repository, this._authRepository) : super(const AsyncValue.data(null));

  Future<void> completeOnboarding({
    required String name,
    required MenopauseStage stage,
    int? cycleLength,
    int? periodDuration,
  }) async {
    if (_repository == null || _authRepository == null) return;
    
    state = const AsyncValue.loading();
    try {
      final authUser = _authRepository!.currentUser; // Get current user
      if (authUser == null) {
        state = AsyncValue.error('User not authenticated', StackTrace.current);
        return;
      }

      final profile = UserProfile()
        ..userId = authUser.uid // Set user ID
        ..name = name
        ..stage = stage
        ..cycleLength = cycleLength
        ..periodDuration = periodDuration
        ..isOnboardingCompleted = true;

      await _repository!.saveUserProfile(profile);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
