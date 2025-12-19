import 'package:isar/isar.dart';

part 'user_profile.g.dart';

enum MenopauseStage {
  regularPeriod,
  perimenopause,
  menopause,
  postMenopause,
  unknown;

  String get displayName {
    switch (this) {
      case MenopauseStage.regularPeriod: return 'Regular Period';
      case MenopauseStage.perimenopause: return 'Perimenopause';
      case MenopauseStage.menopause: return 'Menopause';
      case MenopauseStage.postMenopause: return 'Post-Menopause';
      case MenopauseStage.unknown: return 'Unknown';
    }
  }
}

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  String? name;

  /// Age of the user
  int? age;

  /// Selected stage of menopause journey
  @enumerated
  MenopauseStage stage = MenopauseStage.unknown;

  /// Average cycle length in days (e.g., 28)
  int? cycleLength;

  /// Average period duration in days (e.g., 5)
  int? periodDuration;

  /// specific symptom goals (e.g., "Sleep", "Hot Flashes")
  List<String> goals = [];

  /// Has the user completed onboarding?
  bool isOnboardingCompleted = false;
}
