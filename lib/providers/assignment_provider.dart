import 'package:flutter/material.dart';

import '../models/assignment.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class AssignmentProvider extends ChangeNotifier {
  AssignmentProvider(this._hiveService);

  final HiveService _hiveService;
  final List<Assignment> _assignments = [];

  String query = '';

  List<Assignment> get assignments {
    final normalized = query.trim().toLowerCase();
    final filtered = normalized.isEmpty
        ? _assignments
        : _assignments.where(
            (task) =>
                task.title.toLowerCase().contains(normalized) ||
                task.subject.toLowerCase().contains(normalized),
          );
    final items = filtered.toList();
    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  int get pendingCount =>
      _assignments.where((task) => !task.isCompleted).length;

  void load() {
    _assignments
      ..clear()
      ..addAll(
        _hiveService.values(HiveService.assignmentBox).map(Assignment.fromMap),
      );
    notifyListeners();
  }

  void updateQuery(String value) {
    query = value;
    notifyListeners();
  }

  Future<void> save(Assignment assignment) async {
    final index = _assignments.indexWhere((item) => item.id == assignment.id);
    if (index == -1) {
      _assignments.add(assignment);
    } else {
      _assignments[index] = assignment;
    }
    await _hiveService.put(
      HiveService.assignmentBox,
      assignment.id,
      assignment.toMap(),
    );
    await NotificationService.instance.scheduleReminder(
      id: assignment.id.hashCode,
      title: 'Assignment due soon',
      body: '${assignment.title} is due for ${assignment.subject}.',
      scheduledFor: assignment.dueDate.subtract(const Duration(hours: 18)),
    );
    notifyListeners();
  }

  Future<void> toggleStatus(Assignment assignment) {
    return save(
      assignment.copyWith(
        status: assignment.isCompleted
            ? AssignmentStatus.pending
            : AssignmentStatus.completed,
      ),
    );
  }

  Future<void> remove(String id) async {
    _assignments.removeWhere((task) => task.id == id);
    await NotificationService.instance.cancel(id.hashCode);
    await _hiveService.delete(HiveService.assignmentBox, id);
    notifyListeners();
  }
}
