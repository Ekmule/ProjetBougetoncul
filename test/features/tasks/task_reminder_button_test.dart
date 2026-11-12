import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/tasks/widgets/task_reminder_button.dart';

import '../../test_app_shell.dart';

void main() {
  testWidgets('la cloche active directement la super alerte', (tester) async {
    bool? enabled;
    final task = Task.createNew(id: 'task-1', title: 'Tester MYA');

    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: TaskReminderButton(
            task: task,
            onSetSuperAlert: (value) => enabled = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.notifications_outlined));

    expect(enabled, isTrue);
  });
}
