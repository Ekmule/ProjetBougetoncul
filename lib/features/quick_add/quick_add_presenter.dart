import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/features/quick_add/quick_add_actions.dart';
import 'package:mya/features/quick_add/widgets/quick_add_form.dart';

/// Affiche la création rapide (dialogue ou bottom sheet).
abstract final class QuickAddPresenter {
  /// Dialogue compact — pastille Windows (Ctrl+Alt+Space).
  static Future<void> showQuickAddDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('MYA'),
          content: QuickAddForm(
            onCancel: () => Navigator.of(dialogContext).pop(),
            onSubmit: (input) async {
              final added = await QuickAddActions.submit(ref, input);
              if (!dialogContext.mounted) return;
              if (added) {
                Navigator.of(dialogContext).pop();
                QuickAddActions.showSuccessSnackBar(context);
              }
            },
          ),
        );
      },
    );
  }

  /// Bottom sheet — écran principal mobile (FAB).
  static Future<void> showQuickAddSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
          ),
          child: QuickAddForm(
            onCancel: () => Navigator.of(sheetContext).pop(),
            onSubmit: (input) async {
              final added = await QuickAddActions.submit(ref, input);
              if (!sheetContext.mounted) return;
              if (added) {
                Navigator.of(sheetContext).pop();
                QuickAddActions.showSuccessSnackBar(context);
              }
            },
          ),
        );
      },
    );
  }
}

/// Barre inline en haut de liste — saisie titre seule (flux le plus rapide).
class QuickAddInlineBar extends ConsumerWidget {
  const QuickAddInlineBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: QuickAddForm(
        dense: true,
        showCategoryOptions: false,
        autofocus: false,
        onSubmit: (input) async {
          final added = await QuickAddActions.submit(ref, input);
          if (added && context.mounted) {
            QuickAddActions.showSuccessSnackBar(context);
          }
        },
      ),
    );
  }
}
