import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/widgets/time_format.dart';

void main() {
  test('formats pomodoro timer values', () {
    expect(formatTimer(const Duration(minutes: 25)), '25:00');
    expect(formatTimer(const Duration(minutes: 4, seconds: 9)), '04:09');
  });
}
