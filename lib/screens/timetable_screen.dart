import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timetable_entry.dart';
import '../providers/timetable_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/pill_label.dart';
import '../widgets/time_format.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _weekday = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimetableProvider>();
    final entries = provider.entriesForDay(_weekday);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 92),
        child: FloatingActionButton.extended(
          onPressed: () => _showEntryDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Class'),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 76,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final day = index + 1;
                return ChoiceChip(
                  label: Text(compactWeekday(day)),
                  selected: _weekday == day,
                  onSelected: (_) => setState(() => _weekday = day),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: 7,
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.calendar_month,
                    title: 'No classes here',
                    message: 'Add subjects and time slots to build your week.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return AppCard(
                        padding: const EdgeInsets.all(18),
                        onTap: () => _showEntryDialog(context, entry: entry),
                        child: Row(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Color(
                                  entry.colorValue,
                                ).withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child: Icon(
                                Icons.menu_book_outlined,
                                color: Color(entry.colorValue),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.subject,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.location.isEmpty
                                        ? weekdayName(entry.weekday)
                                        : entry.location,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  PillLabel(
                                    label:
                                        '${minutesToTime(entry.startMinutes)} - ${minutesToTime(entry.endMinutes)}',
                                    icon: Icons.schedule_rounded,
                                    color: Color(entry.colorValue),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => provider.remove(entry.id),
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

  Future<void> _showEntryDialog(
    BuildContext context, {
    TimetableEntry? entry,
  }) async {
    final subject = TextEditingController(text: entry?.subject ?? '');
    final location = TextEditingController(text: entry?.location ?? '');
    var weekday = entry?.weekday ?? _weekday;
    var start = _timeFromMinutes(entry?.startMinutes ?? 9 * 60);
    var end = _timeFromMinutes(entry?.endMinutes ?? 10 * 60);
    var color = entry?.colorValue ?? 0xFF2563EB;

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
                    entry == null ? 'Add class' : 'Edit class',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: weekday,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: List.generate(
                      7,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(weekdayName(index + 1)),
                      ),
                    ),
                    onChanged: (value) =>
                        setSheetState(() => weekday = value ?? weekday),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text(start.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: start,
                            );
                            if (picked != null) {
                              setSheetState(() => start = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text(end.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: end,
                            );
                            if (picked != null) {
                              setSheetState(() => end = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          0xFF2563EB,
                          0xFF059669,
                          0xFFDC2626,
                          0xFF7C3AED,
                          0xFFEA580C,
                        ].map((value) {
                          return ChoiceChip(
                            label: const SizedBox(width: 16, height: 16),
                            selected: color == value,
                            avatar: CircleAvatar(backgroundColor: Color(value)),
                            onSelected: (_) =>
                                setSheetState(() => color = value),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (subject.text.trim().isEmpty) return;
                      context.read<TimetableProvider>().save(
                        TimetableEntry(
                          id:
                              entry?.id ??
                              DateTime.now().microsecondsSinceEpoch.toString(),
                          subject: subject.text.trim(),
                          location: location.text.trim(),
                          weekday: weekday,
                          startMinutes: start.hour * 60 + start.minute,
                          endMinutes: end.hour * 60 + end.minute,
                          colorValue: color,
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

  TimeOfDay _timeFromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
