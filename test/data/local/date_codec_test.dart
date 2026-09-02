import 'package:flutter_test/flutter_test.dart';
import 'package:mya/data/local/date_codec.dart';

void main() {
  test('toPlannedDateString formate YYYY-MM-DD', () {
    expect(
      DateCodec.toPlannedDateString(DateTime(2026, 3, 5)),
      '2026-03-05',
    );
  });

  test('fromPlannedDateString parse une date locale', () {
    expect(
      DateCodec.fromPlannedDateString('2026-03-05'),
      DateTime(2026, 3, 5),
    );
  });

  test('UTC millis round-trip conserve l instant local', () {
    final local = DateTime(2026, 3, 15, 14, 30);
    final restored = DateCodec.fromUtcMillis(DateCodec.toUtcMillis(local));

    expect(restored.year, local.year);
    expect(restored.hour, local.hour);
    expect(restored.minute, local.minute);
  });
}
