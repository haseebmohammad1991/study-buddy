import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/assignment_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/focus_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timetable_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pill_label.dart';
import '../widgets/section_header.dart';
import '../widgets/time_format.dart';
import 'exams_screen.dart';
import 'profile_stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableProvider>();
    final exams = context.watch<ExamProvider>();
    final streak = context.watch<StreakProvider>();
    final tasks = context.watch<AssignmentProvider>();
    final focus = context.watch<FocusProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).colorScheme;
    final greeting = DateTime.now().hour < 12
        ? 'Good morning'
        : DateTime.now().hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink(), toolbarHeight: 8),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready for a calm study day?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: themeProvider.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                onPressed: context.read<ThemeProvider>().toggleTheme,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    key: ValueKey(themeProvider.themeMode),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Profile and stats',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileStatsScreen()),
                ),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6577FF), Color(0xFFA78BFA)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Today in focus',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const PillLabel(
                      label: 'Active streak',
                      icon: Icons.local_fire_department_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${tasks.pendingCount} tasks waiting - ${focus.completedToday} focus sessions done.',
                  style: const TextStyle(
                    color: Color(0xFFEFF2FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final button = GradientButton(
                      label: 'Start Focus',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        context.read<FocusProvider>().start();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Focus session started'),
                          ),
                        );
                      },
                    );
                    if (constraints.maxWidth < 360) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroMetric(
                            value: '${streak.count}',
                            label: 'day streak',
                          ),
                          const SizedBox(height: 16),
                          button,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _HeroMetric(
                            value: '${streak.count}',
                            label: 'day streak',
                          ),
                        ),
                        button,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SectionHeader(
            title: 'Next Exam',
            actionLabel: 'Manage',
            onAction: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ExamsScreen())),
          ),
          if (exams.nearestExam == null)
            const AppCard(child: Text('No upcoming exams yet.'))
          else
            AppCard(
              padding: const EdgeInsets.all(18),
              color: colors.secondaryContainer.withValues(alpha: 0.65),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      color: colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exams.nearestExam!.subject,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: colors.secondary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          exams.nearestExam!.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(formatDateTime(exams.nearestExam!.date)),
                      ],
                    ),
                  ),
                  PillLabel(
                    label: countdownText(exams.nearestExam!.remaining),
                    icon: Icons.schedule_rounded,
                    color: colors.secondary,
                  ),
                ],
              ),
            ),
          const SectionHeader(title: 'Today\'s Timetable'),
          if (timetable.today.isEmpty)
            const AppCard(child: Text('No classes scheduled today.'))
          else
            ...timetable.today
                .take(3)
                .map(
                  (entry) => AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Color(
                              entry.colorValue,
                            ).withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: Color(entry.colorValue),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.subject,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.location),
                            ],
                          ),
                        ),
                        Text(
                          minutesToTime(entry.startMinutes),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.local_fire_department_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(label, style: const TextStyle(color: Color(0xFFEFF2FF))),
          ],
        ),
      ],
    );
  }
}
