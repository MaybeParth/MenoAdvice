import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/onboarding/data/user_profile.dart';
import '../../features/tracker/data/daily_log.dart';

/// Provider to access the Isar instance
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  // Open Isar instance with all schemas
  final isar = await Isar.open(
    [UserProfileSchema, DailyLogSchema],
    directory: dir.path,
    inspector: true, 
  );
  
  return isar;
});
