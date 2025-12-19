import 'package:isar/isar.dart';

part 'daily_log.g.dart';

enum FlowIntensity {
  none,
  light,
  medium,
  heavy;

  String get displayName => name;
}

enum Mood {
  none,
  great,
  good,
  okay,
  anxious,
  sad,
  irritable;

  String get displayName => name;
}

@collection
class DailyLog {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime date;

  @Index()
  late String userId;

  @enumerated
  FlowIntensity flow = FlowIntensity.none;

  @enumerated
  Mood mood = Mood.none;

  /// List of symptom tags e.g. "Hot Flash", "Cramps", "Headache"
  List<String> symptoms = [];

  String? notes;
  
  /// Sleep duration in hours
  double? sleepHours;
}
