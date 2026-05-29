import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/hive_service.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider(this._hiveService);

  final HiveService _hiveService;
  final List<StudyNote> _notes = [];

  String query = '';

  List<StudyNote> get notes {
    final normalized = query.trim().toLowerCase();
    final filtered = normalized.isEmpty
        ? _notes
        : _notes.where(
            (note) =>
                note.title.toLowerCase().contains(normalized) ||
                note.subject.toLowerCase().contains(normalized) ||
                note.body.toLowerCase().contains(normalized),
          );
    final items = filtered.toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  void load() {
    _notes
      ..clear()
      ..addAll(
        _hiveService.values(HiveService.notesBox).map(StudyNote.fromMap),
      );
    notifyListeners();
  }

  void updateQuery(String value) {
    query = value;
    notifyListeners();
  }

  Future<void> save(StudyNote note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    final index = _notes.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      _notes.add(updated);
    } else {
      _notes[index] = updated;
    }
    await _hiveService.put(HiveService.notesBox, updated.id, updated.toMap());
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _hiveService.delete(HiveService.notesBox, id);
    notifyListeners();
  }
}
