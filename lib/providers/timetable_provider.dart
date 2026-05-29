import 'package:flutter/material.dart';

import '../models/timetable_entry.dart';
import '../services/hive_service.dart';

class TimetableProvider extends ChangeNotifier {
  TimetableProvider(this._hiveService);

  final HiveService _hiveService;
  final List<TimetableEntry> _entries = [];

  List<TimetableEntry> get entries => List.unmodifiable(_sorted(_entries));

  List<TimetableEntry> entriesForDay(int weekday) {
    return _sorted(_entries.where((entry) => entry.weekday == weekday));
  }

  List<TimetableEntry> get today => entriesForDay(DateTime.now().weekday);

  void load() {
    _entries
      ..clear()
      ..addAll(
        _hiveService
            .values(HiveService.timetableBox)
            .map(TimetableEntry.fromMap),
      );
    notifyListeners();
  }

  Future<void> save(TimetableEntry entry) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
    await _hiveService.put(HiveService.timetableBox, entry.id, entry.toMap());
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _hiveService.delete(HiveService.timetableBox, id);
    notifyListeners();
  }

  List<TimetableEntry> _sorted(Iterable<TimetableEntry> source) {
    final items = source.toList();
    items.sort((a, b) {
      final dayCompare = a.weekday.compareTo(b.weekday);
      if (dayCompare != 0) return dayCompare;
      return a.startMinutes.compareTo(b.startMinutes);
    });
    return items;
  }
}
