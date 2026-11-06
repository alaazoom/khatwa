class ProgressPoint {
  const ProgressPoint({required this.date, required this.percent});

  final DateTime date;
  final int percent;

  factory ProgressPoint.fromJson(Map<String, dynamic> json) => ProgressPoint(
        date: DateTime.parse(json['date'] as String),
        percent: (json['percent'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'percent': percent,
      };
}

class ReportNote {
  const ReportNote({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  factory ReportNote.fromJson(Map<String, dynamic> json) => ReportNote(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ChildReport {
  const ChildReport({
    required this.independentAreas,
    required this.cardsInUse,
    required this.routineCompletion,
    required this.progress,
    required this.notes,
  });

  final int independentAreas;
  final int cardsInUse;
  final int routineCompletion;
  final List<ProgressPoint> progress;
  final List<ReportNote> notes;

  factory ChildReport.fromJson(Map<String, dynamic> json) => ChildReport(
        independentAreas: (json['independentAreas'] as num).toInt(),
        cardsInUse: (json['cardsInUse'] as num).toInt(),
        routineCompletion: (json['routineCompletion'] as num).toInt(),
        progress: (json['progress'] as List<dynamic>? ?? const [])
            .map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: (json['notes'] as List<dynamic>? ?? const [])
            .map((e) => ReportNote.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'independentAreas': independentAreas,
        'cardsInUse': cardsInUse,
        'routineCompletion': routineCompletion,
        'progress': progress.map((p) => p.toJson()).toList(),
        'notes': notes.map((n) => n.toJson()).toList(),
      };
}