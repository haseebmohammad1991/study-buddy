import 'package:flutter/material.dart';

import '../services/hive_service.dart';

class StreakProvider extends ChangeNotifier {
  StreakProvider(this._hiveService);

  final HiveService _hiveService;

  int _count = 0;
  DateTime? _lastStudyDay;

  int get count => _count;

  String get badge {
    if (_count >= 30) return 'Monthly master';
    if (_count >= 14) return 'Two-week builder';
    if (_count >= 7) return 'Weekly warrior';
    if (_count >= 3) return 'Momentum';
    return 'Fresh start';
  }

  Future<void> load() async {
    _count = await _hiveService.setting<int>('streakCount') ?? 0;
    final raw = await _hiveService.setting<String>('lastStudyDay');
    _lastStudyDay = raw == null ? null : DateTime.tryParse(raw);
    await recordStudySession();
  }

  Future<void> recordStudySession() async {
    final today = _dateOnly(DateTime.now());
    final last = _lastStudyDay == null ? null : _dateOnly(_lastStudyDay!);
    if (last == today) {
      notifyListeners();
      return;
    }

    if (last == today.subtract(const Duration(days: 1))) {
      _count += 1;
    } else {
      _count = 1;
    }

    _lastStudyDay = today;
    await _hiveService.setSetting('streakCount', _count);
    await _hiveService.setSetting('lastStudyDay', today.toIso8601String());
    notifyListeners();
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
