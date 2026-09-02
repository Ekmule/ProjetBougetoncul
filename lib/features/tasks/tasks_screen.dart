import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/features/quick_add/quick_add_presenter.dart';
import 'package:mya/features/tasks/widgets/task_category_list.dart';

/// Interface principale MYA — liste globale par catégories (D4).
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(taskListStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MYA'), centerTitle: false),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Création rapide',
        onPressed: () => QuickAddPresenter.showQuickAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QuickAddInlineBar(),
          Expanded(
            child: TaskCategoryList(
              groupedTasks: listState.grouped,
              completedTasks: listState.completed,
              showEmptySections: true,
              onComplete: (id) =>
                  ref.read(tasksProvider.notifier).completeTask(id),
              onReopen: (id) => ref.read(tasksProvider.notifier).reopenTask(id),
              onMoveCategory: (id, category) => ref
                  .read(tasksProvider.notifier)
                  .moveTaskToCategory(id, category),
              onSetPlannedDate: (id, date) =>
                  ref.read(tasksProvider.notifier).setTaskPlannedDate(id, date),
              onClearPlannedDate: (id) =>
                  ref.read(tasksProvider.notifier).clearTaskPlannedDate(id),
              onSetReminder: (id, when) =>
                  ref.read(tasksProvider.notifier).setTaskReminder(id, when),
              onClearReminder: (id) =>
                  ref.read(tasksProvider.notifier).clearTaskReminder(id),
              onEditTitle: (id, title) =>
                  ref.read(tasksProvider.notifier).updateTaskTitle(id, title),
              onDelete: (id) => ref.read(tasksProvider.notifier).deleteTask(id),
            ),
          ),
        ],
      ),
    );
  }
}
