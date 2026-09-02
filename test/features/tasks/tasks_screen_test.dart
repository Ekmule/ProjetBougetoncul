import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/tasks/tasks_screen.dart';

void main() {
  testWidgets('TasksScreen affiche les catégories principales', (tester) async {
    final emptyGrouped = {
      for (final id in TaskCategoryId.values) id: <Task>[],
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskListStateProvider.overrideWith(
            (ref) => TaskListState(
              grouped: emptyGrouped,
              completed: const [],
            ),
          ),
        ],
        child: const MaterialApp(home: TasksScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BOUGE TON GROS CUL'), findsOneWidget);
    expect(find.text('AUJOURD\'HUI'), findsOneWidget);
    expect(find.text('ENSUITE'), findsOneWidget);
    expect(find.text('À FAIRE SI J\'AI LE TEMPS'), findsOneWidget);
    expect(find.text('+ Ajouter un pense-bête'), findsOneWidget);
  });
}
