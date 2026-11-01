import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/reminders/reminder_providers.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/domain/entities/task.dart';

void main() {
  test('détecte une super alerte sans rappel horaire', () {
    final now = DateTime.now();
    final task = Task.createNew(
      id: 'super-alert-without-reminder',
      title: 'À faire aujourd’hui',
      plannedDate: now,
      superAlertEnabled: true,
      now: now,
    );
    final container = ProviderContainer(
      overrides: [
        taskListStateProvider.overrideWith(
          (ref) => TaskListState(
            grouped: {
              TaskCategoryId.today: [task],
            },
            completed: const [],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(pendingSuperAlertProvider), task);
  });
}
