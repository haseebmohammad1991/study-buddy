class Exam {
  const Exam({
    required this.id,
    required this.name,
    required this.date,
    required this.subject,
  });

  final String id;
  final String name;
  final String subject;
  final DateTime date;

  bool get isPast => date.isBefore(DateTime.now());

  Duration get remaining => date.difference(DateTime.now());

  Exam copyWith({String? name, String? subject, DateTime? date}) {
    return Exam(
      id: id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'subject': subject,
    'date': date.toIso8601String(),
  };

  factory Exam.fromMap(Map<dynamic, dynamic> map) {
    return Exam(
      id: map['id'] as String,
      name: map['name'] as String,
      subject: map['subject'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
