enum AssignmentStatus { pending, completed }

class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.status = AssignmentStatus.pending,
    this.createdAt,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final AssignmentStatus status;
  final DateTime? createdAt;

  bool get isCompleted => status == AssignmentStatus.completed;

  bool get isOverdue {
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    return !isCompleted && dueDay.isBefore(currentDay);
  }

  Assignment copyWith({
    String? title,
    String? subject,
    DateTime? dueDate,
    AssignmentStatus? status,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory Assignment.fromMap(Map<dynamic, dynamic> map) {
    return Assignment(
      id: map['id'] as String,
      title: map['title'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      status: AssignmentStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => AssignmentStatus.pending,
      ),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
    );
  }
}
