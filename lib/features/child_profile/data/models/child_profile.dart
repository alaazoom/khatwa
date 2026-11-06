enum CommunicationMethod { picturesAndSound, sound, pictures }

enum SensoryPreference { calmColors, calmSounds, dimLights }

enum DailyGoal { emotions, routine, requests }

enum LessonUnit { communication, emotions, routine }

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.communicationMethod,
    required this.sensoryPreferences,
    required this.goals,
    required this.lessonUnit,
    this.level = 1,
    this.progressPercent = 0,
    this.communicationFilesCount = 0,
    this.pendingSync = false,
  });

  final String id;
  final String name;
  final CommunicationMethod communicationMethod;
  final Set<SensoryPreference> sensoryPreferences;
  final Set<DailyGoal> goals;
  final LessonUnit lessonUnit;
  final int level;
  final int progressPercent;
  final int communicationFilesCount;
  final bool pendingSync;

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        communicationMethod: CommunicationMethod.values
            .byName(json['communicationMethod'] as String),
        sensoryPreferences:
            _enumSet(SensoryPreference.values, json['sensoryPreferences']),
        goals: _enumSet(DailyGoal.values, json['goals']),
        lessonUnit: LessonUnit.values.byName(json['lessonUnit'] as String),
        level: json['level'] as int? ?? 1,
        progressPercent: json['progressPercent'] as int? ?? 0,
        communicationFilesCount: json['communicationFilesCount'] as int? ?? 0,
        pendingSync: json['pendingSync'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'communicationMethod': communicationMethod.name,
        'sensoryPreferences': sensoryPreferences.map((e) => e.name).toList(),
        'goals': goals.map((e) => e.name).toList(),
        'lessonUnit': lessonUnit.name,
        'level': level,
        'progressPercent': progressPercent,
        'communicationFilesCount': communicationFilesCount,
        'pendingSync': pendingSync,
      };

  ChildProfile copyWith({
    String? name,
    CommunicationMethod? communicationMethod,
    Set<SensoryPreference>? sensoryPreferences,
    Set<DailyGoal>? goals,
    LessonUnit? lessonUnit,
    int? level,
    int? progressPercent,
    int? communicationFilesCount,
    bool? pendingSync,
  }) =>
      ChildProfile(
        id: id,
        name: name ?? this.name,
        communicationMethod: communicationMethod ?? this.communicationMethod,
        sensoryPreferences: sensoryPreferences ?? this.sensoryPreferences,
        goals: goals ?? this.goals,
        lessonUnit: lessonUnit ?? this.lessonUnit,
        level: level ?? this.level,
        progressPercent: progressPercent ?? this.progressPercent,
        communicationFilesCount:
            communicationFilesCount ?? this.communicationFilesCount,
        pendingSync: pendingSync ?? this.pendingSync,
      );

  static Set<T> _enumSet<T extends Enum>(List<T> values, Object? raw) =>
      (raw as List<dynamic>? ?? const [])
          .map((e) => values.byName(e as String))
          .toSet();
}