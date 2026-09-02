import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/history_settings.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_history_service.dart';

void main() {
  const service = TaskHistoryService();
  final now = DateTime(2026, 3, 15);

  Task completedTask({required DateTime completedAt}) {
    return Task.createNew(
      id: 't1',
      title: 'Done',
      now: completedAt,
    ).complete(now: completedAt);
  }

  test('conserve les tâches terminées dans la fenêtre de rétention', () {
    final recent = completedTask(completedAt: DateTime(2026, 3, 14));
    final old = completedTask(completedAt: DateTime(2026, 3, 7));

    final visible = service.filterVisibleCompleted(
      [recent, old],
      now,
      HistorySettings.defaultRetentionDays,
    );

    expect(visible, [recent]);
    expect(service.isWithinRetention(recent, now, 7), isTrue);
    expect(service.isWithinRetention(old, now, 7), isFalse);
  });

  test('findExpiredCompleted retourne les tâches à purger', () {
    final recent = completedTask(completedAt: DateTime(2026, 3, 14));
    final old = completedTask(completedAt: DateTime(2026, 3, 7));

    final expired = service.findExpiredCompleted(
      [recent, old],
      now,
      HistorySettings.defaultRetentionDays,
    );

    expect(expired, [old]);
  });

  test('tri par date de complétion décroissante', () {
    final older = completedTask(completedAt: DateTime(2026, 3, 10));
    final newer = completedTask(completedAt: DateTime(2026, 3, 14));

    final visible = service.filterVisibleCompleted(
      [older, newer],
      now,
      7,
    );

    expect(visible.first.id, newer.id);
  });
}
