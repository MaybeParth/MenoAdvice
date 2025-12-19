import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/database/local_database.dart';
import 'user_profile.dart';
import '../data/onboarding_repository.dart'; // Assuming this provides onboardingRepositoryProvider

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) async* {
  final authUserAsync = ref.watch(authStateChangesProvider);
  
  if (authUserAsync.isLoading) {
    yield null; // Or handle loading state differently, e.g., yield a loading indicator
    return; // Exit if still loading
  }
  
  final authUser = authUserAsync.value;
  if (authUser == null) {
    yield null;
  } else {
    // Watch profile for this specific user
    final repo = ref.watch(onboardingRepositoryProvider);
    yield* repo.watchUserProfile(authUser.uid);
  }
});
