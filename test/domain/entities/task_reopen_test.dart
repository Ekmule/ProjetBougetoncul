import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';

void main() {
  test('reopen remet une tâche en active et efface completedAt', () {
    final now = DateTime(2026, 3, 15);
    final task = Task.createNew(id: 't1', title: 'Test', now: now).complete(
      now: now,
    );

    final reopened = task.reopen(now: now);

    expect(reopened.status, TaskStatus.active);
    expect(reopened.completedAt, isNull);
    expect(reopened.isActive, isTrue);
  });
}
