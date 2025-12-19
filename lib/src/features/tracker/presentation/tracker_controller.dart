import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/daily_log.dart';
import '../data/tracker_repository.dart';
import '../../auth/data/auth_repository.dart';

// UI State: viewing a specific month
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// Logs for the selected month
final monthlyLogsProvider = StreamProvider.autoDispose<List<DailyLog>>((ref) {
  final repo = ref.watch(trackerRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return const Stream.empty();
  return repo.watchLogsForMonth(month, user.uid);
});

// Controller for editing/saving a log
final trackerControllerProvider = StateNotifierProvider<TrackerController, AsyncValue<void>>((ref) {
  final repo = ref.watch(trackerRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return TrackerController(repo, authRepo);
});

final logForDateProvider = FutureProvider.family.autoDispose<DailyLog?, DateTime>((ref, date) {
  final repo = ref.watch(trackerRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return null;
  return repo.getLogForDate(date, user.uid);
});

class TrackerController extends StateNotifier<AsyncValue<void>> {
  final TrackerRepository _repository;
  final AuthRepository _authRepository;

  TrackerController(this._repository, this._authRepository) : super(const AsyncValue.data(null));

  Future<void> saveLog(DailyLog log) async {
    state = const AsyncValue.loading();
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Ensure user ID is set
      log.userId = user.uid;
        
      await _repository.saveLog(log);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
