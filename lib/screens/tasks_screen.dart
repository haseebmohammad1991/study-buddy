import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/pill_label.dart';
import '../widgets/time_format.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final tasks = provider.assignments;

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 92),
        child: FloatingActionButton.extended(
          onPressed: () => _showTaskDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Task'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: SearchBar(
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surface,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              leading: const Icon(Icons.search),
              hintText: 'Search tasks',
              onChanged: context.read<AssignmentProvider>().updateQuery,
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const EmptyState(
                    icon: Icons.checklist,
                    title: 'Nothing to track',
                    message: 'Add assignments and due dates to stay ahead.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final colors = Theme.of(context).colorScheme;
                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () => _showTaskDialog(context, task: task),
                        color: task.isOverdue
                            ? colors.errorContainer.withValues(alpha: 0.68)
                            : colors.surface,
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => context
                                  .read<AssignmentProvider>()
                                  .toggleStatus(task),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(task.subject),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      PillLabel(
                                        label: formatDate(task.dueDate),
                                        icon: Icons.event_outlined,
                                        color: task.isOverdue
                                            ? colors.error
                                            : colors.primary,
                                      ),
                                      if (task.isOverdue)
                                        PillLabel(
                                          label: 'Overdue',
                                          icon: Icons.warning_amber_rounded,
                                          color: colors.error,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context
                                  .read<AssignmentProvider>()
                                  .remove(task.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskDialog(BuildContext context, {Assignment? task}) async {
    final title = TextEditingController(text: task?.title ?? '');
    final subject = TextEditingController(text: task?.subject ?? '');
    var dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    var status = task?.status ?? AssignmentStatus.pending;

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
                    task == null ? 'Add assignment' : 'Edit assignment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event),
                    label: Text(formatDate(dueDate)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 3),
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => dueDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<AssignmentStatus>(
                    segments: const [
                      ButtonSegment(
                        value: AssignmentStatus.pending,
                        label: Text('Pending'),
                        icon: Icon(Icons.radio_button_unchecked),
                      ),
                      ButtonSegment(
                        value: AssignmentStatus.completed,
                        label: Text('Done'),
                        icon: Icon(Icons.check_circle_outline),
                      ),
                    ],
                    selected: {status},
                    onSelectionChanged: (value) =>
                        setSheetState(() => status = value.first),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (title.text.trim().isEmpty ||
                          subject.text.trim().isEmpty) {
                        return;
                      }
                      context.read<AssignmentProvider>().save(
                        Assignment(
                          id:
                              task?.id ??
                              DateTime.now().microsecondsSinceEpoch.toString(),
                          title: title.text.trim(),
                          subject: subject.text.trim(),
                          dueDate: dueDate,
                          status: status,
                          createdAt: task?.createdAt,
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
