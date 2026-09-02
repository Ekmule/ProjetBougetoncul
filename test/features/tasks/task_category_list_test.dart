import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/tasks/widgets/task_category_list.dart';
import 'package:mya/features/tasks/widgets/task_list_tile.dart';

void main() {
  testWidgets(
    'aperçu conserve toutes les tâches et permet de les faire défiler',
    (tester) async {
      final tasks = List.generate(
        6,
        (index) => Task.createNew(
          id: 'task-$index',
          title: 'Tâche ${index + 1}',
          now: DateTime(2026),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 180,
              child: TaskCategoryList(
                groupedTasks: {TaskCategoryId.next: tasks},
                completedTasks: const [],
                isPreview: true,
                onComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TaskListTile), findsNWidgets(6));

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.maxScrollExtent, greaterThan(0));

      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, greaterThan(0));
    },
  );
}
