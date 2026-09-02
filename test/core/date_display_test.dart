import 'package:flutter_test/flutter_test.dart';
import 'package:mya/core/utils/date_display.dart';

void main() {
  test('reminderDateTime formate date et heure', () {
    final formatted = DateDisplay.reminderDateTime(
      DateTime(2026, 8, 25, 14),
    );

    expect(formatted, '25 août à 14h00');
  });
}
