import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exam.dart';
import '../providers/exam_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/pill_label.dart';
import '../widgets/time_format.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = context.watch<ExamProvider>().exams;

    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 92),
        child: FloatingActionButton.extended(
          onPressed: () => _showExamDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Exam'),
        ),
      ),
      body: exams.isEmpty
          ? const EmptyState(
              icon: Icons.event_available,
              title: 'No exams yet',
              message: 'Add exam dates to keep countdowns visible.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                final colors = Theme.of(context).colorScheme;
                return AppCard(
                  padding: const EdgeInsets.all(18),
                  onTap: () => _showExamDialog(context, exam: exam),
                  color: colors.secondaryContainer.withValues(alpha: 0.55),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
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
                              '${exam.subject}: ${exam.name}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(formatDateTime(exam.date)),
                            const SizedBox(height: 10),
                            PillLabel(
                              label: countdownText(exam.remaining),
                              icon: Icons.schedule_rounded,
                              color: colors.secondary,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            context.read<ExamProvider>().remove(exam.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showExamDialog(BuildContext context, {Exam? exam}) async {
    final name = TextEditingController(text: exam?.name ?? '');
    final subject = TextEditingController(text: exam?.subject ?? '');
    var date = exam?.date ?? DateTime.now().add(const Duration(days: 7));
    var time = TimeOfDay.fromDateTime(date);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exam == null ? 'Add exam' : 'Edit exam',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Exam name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event),
                          label: Text(formatDate(date)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 5),
                              ),
                            );
                            if (picked != null) {
                              setSheetState(() => date = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text(time.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (picked != null) {
                              setSheetState(() => time = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (name.text.trim().isEmpty ||
                          subject.text.trim().isEmpty) {
                        return;
                      }
                      final finalDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      context.read<ExamProvider>().save(
                        Exam(
                          id:
                              exam?.id ??
                              DateTime.now().microsecondsSinceEpoch.toString(),
                          name: name.text.trim(),
                          subject: subject.text.trim(),
                          date: finalDate,
                        ),
                      );
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
