import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_date_service.dart';

void main() {
  const service = TaskDateService();
  final today = DateTime(2026, 3, 15);

  test('isOverdue détecte une date passée', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Retard',
      plannedDate: DateTime(2026, 3, 10),
      now: today,
    );

    expect(service.isOverdue(task, today), isTrue);
    expect(service.isDueToday(task, today), isFalse);
  });

  test('isDueToday détecte la date du jour', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Aujourd hui',
      plannedDate: today,
      now: today,
    );

    expect(service.isDueToday(task, today), isTrue);
    expect(service.isOverdue(task, today), isFalse);
  });

  test('setPlannedDate normalise sans heure', () {
    final task = Task.createNew(id: 't1', title: 'Test', now: today);
    final updated = service.setPlannedDate(
      task,
      DateTime(2026, 8, 25, 14, 30),
      now: today,
    );

    expect(updated.plannedDate, DateTime(2026, 8, 25));
  });

  test('clearPlannedDate retire la date', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Test',
      plannedDate: today,
      now: today,
    );

    expect(service.clearPlannedDate(task, now: today).plannedDate, isNull);
  });
}
