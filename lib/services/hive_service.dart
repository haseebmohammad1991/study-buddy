import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const timetableBox = 'timetable_entries';
  static const assignmentBox = 'assignments';
  static const notesBox = 'notes';
  static const examsBox = 'exams';
  static const focusBox = 'focus_sessions';
  static const settingsBox = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(timetableBox),
      Hive.openBox(assignmentBox),
      Hive.openBox(notesBox),
      Hive.openBox(examsBox),
      Hive.openBox(focusBox),
      Hive.openBox(settingsBox),
    ]);
    await _seedIfNeeded();
  }

  Box box(String name) => Hive.box(name);

  List<Map<dynamic, dynamic>> values(String boxName) {
    return box(boxName).values
        .whereType<Map>()
        .map((value) => Map<dynamic, dynamic>.from(value))
        .toList();
  }

  Future<void> put(String boxName, String id, Map<String, dynamic> value) {
    return box(boxName).put(id, value);
  }

  Future<void> delete(String boxName, String id) {
    return box(boxName).delete(id);
  }

  Future<T?> setting<T>(String key) async {
    return box(settingsBox).get(key) as T?;
  }

  Future<void> setSetting(String key, Object? value) {
    return box(settingsBox).put(key, value);
  }

  Future<void> _seedIfNeeded() async {
    final settings = box(settingsBox);
    if (settings.get('seeded') == true) return;

    final now = DateTime.now();
    final today = now.weekday;

    await box(timetableBox).putAll({
      'tt_math': {
        'id': 'tt_math',
        'subject': 'Calculus',
        'location': 'Room 204',
        'weekday': today,
        'startMinutes': 9 * 60,
        'endMinutes': 10 * 60 + 15,
        'colorValue': 0xFF2563EB,
      },
      'tt_physics': {
        'id': 'tt_physics',
        'subject': 'Physics Lab',
        'location': 'Lab 3',
        'weekday': today,
        'startMinutes': 13 * 60,
        'endMinutes': 14 * 60 + 30,
        'colorValue': 0xFF059669,
      },
      'tt_english': {
        'id': 'tt_english',
        'subject': 'Academic Writing',
        'location': 'Room 118',
        'weekday': today == 7 ? 1 : today + 1,
        'startMinutes': 11 * 60,
        'endMinutes': 12 * 60,
        'colorValue': 0xFFDC2626,
      },
    });

    await box(assignmentBox).putAll({
      'as_physics': {
        'id': 'as_physics',
        'title': 'Lab report: refraction',
        'subject': 'Physics',
        'dueDate': now.add(const Duration(days: 2)).toIso8601String(),
        'status': 'pending',
        'createdAt': now.toIso8601String(),
      },
      'as_history': {
        'id': 'as_history',
        'title': 'Modern history outline',
        'subject': 'History',
        'dueDate': now.add(const Duration(days: 5)).toIso8601String(),
        'status': 'pending',
        'createdAt': now.toIso8601String(),
      },
      'as_chem': {
        'id': 'as_chem',
        'title': 'Organic chemistry worksheet',
        'subject': 'Chemistry',
        'dueDate': now.subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'pending',
        'createdAt': now.toIso8601String(),
      },
    });

    await box(notesBox).putAll({
      'note_revision': {
        'id': 'note_revision',
        'title': 'Revision checklist',
        'subject': 'General',
        'body':
            '- Review lecture slides\n- Make flashcards\n- Solve past papers',
        'updatedAt': now.toIso8601String(),
      },
      'note_physics': {
        'id': 'note_physics',
        'title': 'Waves summary',
        'subject': 'Physics',
        'body':
            'Frequency, wavelength, and velocity are linked by v = f lambda.',
        'updatedAt': now.subtract(const Duration(hours: 3)).toIso8601String(),
      },
    });

    await box(examsBox).putAll({
      'ex_calc': {
        'id': 'ex_calc',
        'name': 'Midterm Exam',
        'subject': 'Calculus',
        'date': DateTime(now.year, now.month, now.day + 9, 9).toIso8601String(),
      },
      'ex_phys': {
        'id': 'ex_phys',
        'name': 'Practical Test',
        'subject': 'Physics',
        'date': DateTime(
          now.year,
          now.month,
          now.day + 16,
          11,
        ).toIso8601String(),
      },
    });

    await settings.put('streakCount', 0);
    await settings.put('seeded', true);
  }
}
