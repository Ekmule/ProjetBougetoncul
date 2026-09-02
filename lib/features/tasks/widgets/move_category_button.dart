import 'package:flutter/material.dart';
import 'package:mya/core/constants/task_categories.dart';
import 'package:mya/domain/entities/task.dart';

/// Menu de déplacement vers une autre catégorie (D6).
class MoveCategoryButton extends StatelessWidget {
  const MoveCategoryButton({
    super.key,
    required this.task,
    required this.onMove,
  });

  final Task task;
  final void Function(TaskCategoryId category) onMove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskCategoryId>(
      tooltip: 'Déplacer vers…',
      icon: const Icon(Icons.drive_file_move_outline, size: 20),
      onSelected: onMove,
      itemBuilder: (context) {
        return [
          for (final category in TaskCategoryDisplay.displayOrder)
            PopupMenuItem<TaskCategoryId>(
              value: category,
              enabled: category != task.category,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Color(category.colorValue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.defaultLabel,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (category == task.category)
                    const Icon(Icons.check, size: 16),
                ],
              ),
            ),
        ];
      },
    );
  }
}
