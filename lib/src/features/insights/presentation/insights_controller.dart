import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../onboarding/data/user_providers.dart';
import '../../tracker/data/tracker_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../data/ai_repository.dart';

final insightsControllerProvider = StateNotifierProvider<InsightsController, AsyncValue<String>>((ref) {
  final aiRepo = ref.watch(aiRepositoryProvider);
  final trackerRepo = ref.watch(trackerRepositoryProvider);
  // We need to read user profile here or in the method. 
  // Reading provider inside notifier constructor is anti-pattern if dynamic.
  // Better to pass Ref or read in method. 
  return InsightsController(ref, aiRepo, trackerRepo);
});

class InsightsController extends StateNotifier<AsyncValue<String>> {
  final Ref _ref;
  final AiRepository _aiRepository;
  final TrackerRepository _trackerRepository;

  InsightsController(this._ref, this._aiRepository, this._trackerRepository) : super(const AsyncValue.data(''));

  Future<void> generateInsights() async {
    state = const AsyncValue.loading();
    try {
      // 1. Get User Profile for context
      final userAsync = await _ref.read(userProfileStreamProvider.future);
      final userStage = userAsync?.stage.displayName ?? 'Unknown';

      // 2. Get Last 30 days logs
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      // Logic for "last 30 days" across month boundaries is tricky with current repo method `getLogsForMonth`.
      // We might need a `getRecentLogs` in repo or just fetch current and previous month.
      
      // Let's implement a simple fetch for current and previous month to be safe.
      final thisMonthLogs = await _trackerRepository.getLogsForMonth(now, user.uid);
      final prevMonthLogs = await _trackerRepository.getLogsForMonth(DateTime(now.year, now.month - 1), user.uid);
      
      final allLogs = [...prevMonthLogs, ...thisMonthLogs];
      // Filter strictly last 30 days
      final cutoff = now.subtract(const Duration(days: 30));
      final recentLogs = allLogs.where((l) => l.date.isAfter(cutoff)).toList();
      // Sort by date
      recentLogs.sort((a,b) => a.date.compareTo(b.date));

      // 3. Call AI
      final result = await _aiRepository.analyzeLogs(recentLogs, userStage);
      
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
