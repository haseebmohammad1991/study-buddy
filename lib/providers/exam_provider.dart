import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class ExamProvider extends ChangeNotifier {
  ExamProvider(this._hiveService);

  final HiveService _hiveService;
  final List<Exam> _exams = [];

  List<Exam> get exams {
    final items = _exams.toList();
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Exam? get nearestExam {
    final upcoming = exams.where((exam) => !exam.isPast).toList();
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  void load() {
    _exams
      ..clear()
      ..addAll(_hiveService.values(HiveService.examsBox).map(Exam.fromMap));
    notifyListeners();
  }

  Future<void> save(Exam exam) async {
    final index = _exams.indexWhere((item) => item.id == exam.id);
    if (index == -1) {
      _exams.add(exam);
    } else {
      _exams[index] = exam;
    }
    await _hiveService.put(HiveService.examsBox, exam.id, exam.toMap());
    await NotificationService.instance.scheduleReminder(
      id: exam.id.hashCode,
      title: 'Exam reminder',
      body: '${exam.subject}: ${exam.name} is coming up.',
      scheduledFor: exam.date.subtract(const Duration(days: 1)),
    );
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _exams.removeWhere((exam) => exam.id == id);
    await NotificationService.instance.cancel(id.hashCode);
    await _hiveService.delete(HiveService.examsBox, id);
    notifyListeners();
  }
}
