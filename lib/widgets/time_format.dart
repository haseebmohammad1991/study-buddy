import 'package:intl/intl.dart';

String weekdayName(int weekday) {
  const names = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  return names[weekday] ?? 'Monday';
}

String compactWeekday(int weekday) => weekdayName(weekday).substring(0, 3);

String minutesToTime(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  final date = DateTime(2024, 1, 1, hour, minute);
  return DateFormat.jm().format(date);
}

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String formatDateTime(DateTime date) =>
    DateFormat('MMM d, h:mm a').format(date);

String formatTimer(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String countdownText(Duration duration) {
  if (duration.isNegative) return 'Finished';
  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);
  if (days > 0) return '${days}d ${hours}h left';
  return '${hours}h ${minutes}m left';
}
