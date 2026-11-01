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

  test('super alerte se déclenche le jour prévu puis une fois en retard', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Urgent',
      plannedDate: today,
      superAlertEnabled: true,
      now: today,
    );

    expect(service.isSuperAlertDue(task, today), isTrue);

    final acknowledgedToday = service.acknowledgeSuperAlert(
      task,
      now: today.add(const Duration(hours: 10)),
    );
    expect(service.isSuperAlertDue(acknowledgedToday, today), isFalse);

    final tomorrow = today.add(const Duration(days: 1));
    expect(service.isSuperAlertDue(acknowledgedToday, tomorrow), isTrue);

    final acknowledgedOverdue = service.acknowledgeSuperAlert(
      acknowledgedToday,
      now: tomorrow,
    );
    expect(
      service.isSuperAlertDue(
        acknowledgedOverdue,
        tomorrow.add(const Duration(days: 1)),
      ),
      isFalse,
    );
  });

  test('changer la date réarme la super alerte', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Test',
      plannedDate: today,
      superAlertEnabled: true,
      now: today,
    ).copyWith(superAlertAcknowledgedAt: today);

    final updated = service.setPlannedDate(
      task,
      today.add(const Duration(days: 1)),
      now: today,
    );

    expect(updated.superAlertAcknowledgedAt, isNull);
  });
}
