import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/core/database/local_database.dart';
import 'daily_log.dart';

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  // UI should handle loading state
  return TrackerRepository(isarAsync.value!);
});

class TrackerRepository {
  final Isar _isar;

  TrackerRepository(this._isar);

  Future<void> saveLog(DailyLog log) async {
    await _isar.writeTxn(() async {
      await _isar.dailyLogs.put(log); 
    });
  }

  /// Get logs for a specific month and user
  Future<List<DailyLog>> getLogsForMonth(DateTime month, String userId) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return await _isar.dailyLogs
        .filter()
        .userIdEqualTo(userId)
        .dateBetween(start, end, includeUpper: false)
        .findAll();
  }

  Stream<List<DailyLog>> watchLogsForMonth(DateTime month, String userId) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    
     return _isar.dailyLogs
        .filter()
        .userIdEqualTo(userId)
        .dateBetween(start, end, includeUpper: false)
        .watch(fireImmediately: true);
  }
  
  Future<DailyLog?> getLogForDate(DateTime date, String userId) async {
       return await _isar.dailyLogs.filter().userIdEqualTo(userId).dateEqualTo(date).findFirst();
  }
}
