class RoutineItem {
  const RoutineItem({
    required this.id,
    required this.title,
    required this.time,
    required this.iconName,
    this.enabled = true,
  });

  final String id;

  /// مفتاح ترجمة للمهام الافتراضية، أو نص يكتبه المستخدم.
  final String title;

  /// الوقت بصيغة 24 ساعة "HH:mm".
  final String time;
  final String iconName;
  final bool enabled;

  int get hour => int.parse(time.split(':').first);

  int get minute => int.parse(time.split(':').last);

  factory RoutineItem.fromJson(Map<String, dynamic> json) => RoutineItem(
        id: json['id'] as String,
        title: json['title'] as String,
        time: json['time'] as String,
        iconName: json['iconName'] as String,
        enabled: json['enabled'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'iconName': iconName,
        'enabled': enabled,
      };

  RoutineItem copyWith({bool? enabled}) => RoutineItem(
        id: id,
        title: title,
        time: time,
        iconName: iconName,
        enabled: enabled ?? this.enabled,
      );
}