import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/focus_provider.dart';
import '../providers/streak_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/pill_label.dart';
import '../widgets/time_format.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();
    final streak = context.watch<StreakProvider>();
    final isFocus = focus.phase == FocusPhase.focus;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF202438), Color(0xFF171A22)]
                : const [Color(0xFFEAF0FF), Color(0xFFF7F6FC)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
            children: [
              Text(
                'Focus Mode',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFocus
                    ? 'Quiet space for deep work.'
                    : 'Take a mindful break.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B7CFF), Color(0xFFA78BFA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B7CFF).withValues(alpha: 0.28),
                        blurRadius: 38,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.93),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFocus
                                ? Icons.psychology_alt_outlined
                                : Icons.self_improvement_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 34,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isFocus ? 'Focus' : 'Break',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatTimer(focus.remaining),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundAction(
                    icon: Icons.restart_alt_rounded,
                    label: 'Reset',
                    onTap: context.read<FocusProvider>().reset,
                  ),
                  const SizedBox(width: 16),
                  _PrimaryPlayButton(
                    running: focus.running,
                    onTap: focus.running
                        ? context.read<FocusProvider>().pause
                        : context.read<FocusProvider>().start,
                  ),
                  const SizedBox(width: 16),
                  _RoundAction(
                    icon: Icons.done_all_rounded,
                    label: 'Done',
                    onTap: () async {
                      final focusProvider = context.read<FocusProvider>();
                      final streakProvider = context.read<StreakProvider>();
                      await focusProvider.completeCurrentFocus();
                      await streakProvider.recordStudySession();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: _Metric(
                        icon: Icons.today_outlined,
                        label: 'Today',
                        value: '${focus.completedToday}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      child: _Metric(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Streak',
                        value: '${streak.count}',
                      ),
                    ),
                  ),
                ],
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badges',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          label: 'First focus',
                          unlocked: focus.sessions.isNotEmpty,
                        ),
                        _Badge(
                          label: 'Three today',
                          unlocked: focus.completedToday >= 3,
                        ),
                        _Badge(
                          label: '7 day streak',
                          unlocked: streak.count >= 7,
                        ),
                        _Badge(
                          label: '30 day streak',
                          unlocked: streak.count >= 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({required this.running, required this.onTap});

  final bool running;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(34),
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6B7CFF), Color(0xFFA78BFA)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B7CFF).withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          running ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(onPressed: onTap, icon: Icon(icon)),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(label),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.unlocked});

  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return PillLabel(
      icon: unlocked ? Icons.verified_outlined : Icons.lock_outline,
      label: label,
      color: unlocked
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.outline,
    );
  }
}
