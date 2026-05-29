class TimetableEntry {
  const TimetableEntry({
    required this.id,
    required this.subject,
    required this.location,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    this.colorValue = 0xFF2563EB,
  });

  final String id;
  final String subject;
  final String location;
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final int colorValue;

  bool get isToday => weekday == DateTime.now().weekday;

  TimetableEntry copyWith({
    String? subject,
    String? location,
    int? weekday,
    int? startMinutes,
    int? endMinutes,
    int? colorValue,
  }) {
    return TimetableEntry(
      id: id,
      subject: subject ?? this.subject,
      location: location ?? this.location,
      weekday: weekday ?? this.weekday,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'subject': subject,
    'location': location,
    'weekday': weekday,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'colorValue': colorValue,
  };

  factory TimetableEntry.fromMap(Map<dynamic, dynamic> map) {
    return TimetableEntry(
      id: map['id'] as String,
      subject: map['subject'] as String,
      location: (map['location'] as String?) ?? '',
      weekday: map['weekday'] as int,
      startMinutes: map['startMinutes'] as int,
      endMinutes: map['endMinutes'] as int,
      colorValue: (map['colorValue'] as int?) ?? 0xFF2563EB,
    );
  }
}
