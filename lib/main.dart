import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/assignment_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/timetable_provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: hiveService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => TimetableProvider(hiveService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentProvider(hiveService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(hiveService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExamProvider(hiveService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakProvider(hiveService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => FocusProvider(hiveService)..load(),
        ),
      ],
      child: const StudyBuddyApp(),
    ),
  );
}
