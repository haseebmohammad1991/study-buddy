import 'dart:async';

import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../services/hive_service.dart';

enum FocusPhase { focus, breakTime }

class FocusProvider extends ChangeNotifier {
  FocusProvider(this._hiveService);

  static const focusDuration = Duration(minutes: 25);
  static const breakDuration = Duration(minutes: 5);

  final HiveService _hiveService;
  final List<FocusSession> _sessions = [];

  Timer? _timer;
  FocusPhase _phase = FocusPhase.focus;
  Duration _remaining = focusDuration;
  bool _running = false;
  int _completedToday = 0;

  FocusPhase get phase => _phase;
  Duration get remaining => _remaining;
  bool get running => _running;
  int get completedToday => _completedToday;
  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  Map<DateTime, int> get minutesByDay {
    final result = <DateTime, int>{};
    for (final session in _sessions) {
      final day = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      result[day] = (result[day] ?? 0) + session.focusMinutes;
    }
    return result;
  }

  void load() {
    _sessions
      ..clear()
      ..addAll(
        _hiveService.values(HiveService.focusBox).map(FocusSession.fromMap),
      );
    _recountToday();
    notifyListeners();
  }

  void start() {
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    _running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    pause();
    _phase = FocusPhase.focus;
    _remaining = focusDuration;
    notifyListeners();
  }

  Future<void> completeCurrentFocus() async {
    await _recordSession();
    _phase = FocusPhase.breakTime;
    _remaining = breakDuration;
    _recountToday();
    notifyListeners();
  }

  void _tick() {
    if (_remaining.inSeconds > 1) {
      _remaining -= const Duration(seconds: 1);
      notifyListeners();
      return;
    }

    if (_phase == FocusPhase.focus) {
      completeCurrentFocus();
    } else {
      _phase = FocusPhase.focus;
      _remaining = focusDuration;
      notifyListeners();
    }
  }

  Future<void> _recordSession() async {
    final session = FocusSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      focusMinutes: focusDuration.inMinutes,
    );
    _sessions.add(session);
    await _hiveService.put(HiveService.focusBox, session.id, session.toMap());
  }

  void _recountToday() {
    final now = DateTime.now();
    _completedToday = _sessions.where((session) {
      final started = session.startedAt;
      return started.year == now.year &&
          started.month == now.month &&
          started.day == now.day;
    }).length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
