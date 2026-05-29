class StudyNote {
  const StudyNote({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.subject = 'General',
  });

  final String id;
  final String title;
  final String subject;
  final String body;
  final DateTime updatedAt;

  StudyNote copyWith({
    String? title,
    String? subject,
    String? body,
    DateTime? updatedAt,
  }) {
    return StudyNote(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'body': body,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory StudyNote.fromMap(Map<dynamic, dynamic> map) {
    return StudyNote(
      id: map['id'] as String,
      title: map['title'] as String,
      subject: (map['subject'] as String?) ?? 'General',
      body: map['body'] as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
