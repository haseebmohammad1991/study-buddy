class FocusSession {
  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.focusMinutes,
  });

  final String id;
  final DateTime startedAt;
  final int focusMinutes;

  Map<String, dynamic> toMap() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'focusMinutes': focusMinutes,
  };

  factory FocusSession.fromMap(Map<dynamic, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      focusMinutes: map['focusMinutes'] as int,
    );
  }
}
