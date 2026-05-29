import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/assignment_provider.dart';
import '../providers/focus_provider.dart';
import '../providers/streak_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/pill_label.dart';
import '../widgets/section_header.dart';
import '../widgets/time_format.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<StreakProvider>();
    final focus = context.watch<FocusProvider>();
    final tasks = context.watch<AssignmentProvider>();
    final colors = Theme.of(context).colorScheme;
    final totalMinutes = focus.sessions.fold<int>(
      0,
      (sum, session) => sum + session.focusMinutes,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Stats')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
        children: [
          AppCard(
            padding: const EdgeInsets.all(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF5B6EE1), Color(0xFFB18CFE)],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study Buddy',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        streak.badge,
                        style: const TextStyle(color: Color(0xFFEFF2FF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '${streak.count}',
                  label: 'day streak',
                  color: const Color(0xFFEA7A52),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  value: '${(totalMinutes / 60).toStringAsFixed(1)}h',
                  label: 'study time',
                  color: colors.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.task_alt_outlined,
                  value: '${tasks.pendingCount}',
                  label: 'open tasks',
                  color: colors.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.today_outlined,
                  value: '${focus.completedToday}',
                  label: 'today',
                  color: const Color(0xFF10A37F),
                ),
              ),
            ],
          ),
          const SectionHeader(title: 'Badges'),
          AppCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                PillLabel(
                  label: 'First focus',
                  icon: focus.sessions.isNotEmpty
                      ? Icons.verified_outlined
                      : Icons.lock_outline,
                  color: colors.primary,
                ),
                PillLabel(
                  label: 'Three today',
                  icon: focus.completedToday >= 3
                      ? Icons.verified_outlined
                      : Icons.lock_outline,
                  color: colors.secondary,
                ),
                PillLabel(
                  label: 'Weekly streak',
                  icon: streak.count >= 7
                      ? Icons.verified_outlined
                      : Icons.lock_outline,
                  color: const Color(0xFF10A37F),
                ),
                PillLabel(
                  label: 'Monthly master',
                  icon: streak.count >= 30
                      ? Icons.verified_outlined
                      : Icons.lock_outline,
                  color: const Color(0xFFEA7A52),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Recent Study'),
          if (focus.sessions.isEmpty)
            const AppCard(child: Text('Complete a focus session to begin.'))
          else
            ...focus.sessions.reversed
                .take(4)
                .map(
                  (session) => AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.timer_outlined),
                      title: Text('${session.focusMinutes} minutes focused'),
                      subtitle: Text(formatDateTime(session.startedAt)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
