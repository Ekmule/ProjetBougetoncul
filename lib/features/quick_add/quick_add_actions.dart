import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/features/quick_add/models/quick_add_input.dart';

/// Actions partagées pour la création rapide.
abstract final class QuickAddActions {
  /// Persiste une tâche depuis un [QuickAddInput]. Retourne false si titre vide.
  static Future<bool> submit(WidgetRef ref, QuickAddInput input) async {
    if (!input.isValid) return false;

    await ref.read(tasksProvider.notifier).addTask(
          input.trimmedTitle,
          category: input.category,
        );
    return true;
  }

  static void showSuccessSnackBar(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Pense-bête ajouté'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
