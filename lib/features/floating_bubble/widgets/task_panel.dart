import 'package:flutter/material.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/quick_add/quick_add_presenter.dart';
import 'package:mya/features/tasks/widgets/task_category_list.dart';

/// Panneau de tâches de la pastille Windows — version complète ou aperçu.
class TaskPanel extends StatelessWidget {
  const TaskPanel({
    super.key,
    required this.groupedTasks,
    required this.completedTasks,
    required this.isPreview,
    required this.alwaysOnTop,
    required this.onClose,
    required this.onComplete,
    this.onReopen,
    this.onMoveCategory,
    this.onSetPlannedDate,
    this.onClearPlannedDate,
    this.onSetReminder,
    this.onClearReminder,
    this.onEditTitle,
    this.onDelete,
    required this.onToggleAlwaysOnTop,
    required this.onHide,
    this.onExpand,
    this.quickAddHotkeyLabel = 'Ctrl+Alt+Espace',
  });

  final Map<TaskCategoryId, List<Task>> groupedTasks;
  final List<Task> completedTasks;
  final bool isPreview;
  final bool alwaysOnTop;
  final VoidCallback onClose;
  final void Function(String id) onComplete;
  final void Function(String id)? onReopen;
  final void Function(String id, TaskCategoryId category)? onMoveCategory;
  final void Function(String id, DateTime date)? onSetPlannedDate;
  final void Function(String id)? onClearPlannedDate;
  final void Function(String id, DateTime when)? onSetReminder;
  final void Function(String id)? onClearReminder;
  final Future<void> Function(String id, String title)? onEditTitle;
  final Future<void> Function(String id)? onDelete;
  final VoidCallback onToggleAlwaysOnTop;
  final VoidCallback onHide;
  final VoidCallback? onExpand;
  final String quickAddHotkeyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(12),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PanelHeader(
              alwaysOnTop: alwaysOnTop,
              onToggleAlwaysOnTop: onToggleAlwaysOnTop,
              onHide: onHide,
              onClose: onClose,
              onExpand: onExpand,
              compact: isPreview,
            ),
            if (!isPreview) const QuickAddInlineBar(),
            Expanded(
              child: TaskCategoryList(
                groupedTasks: groupedTasks,
                completedTasks: completedTasks,
                isPreview: isPreview,
                showCompleted: !isPreview,
                showEmptySections: !isPreview,
                onComplete: onComplete,
                onReopen: onReopen,
                onMoveCategory: onMoveCategory,
                onSetPlannedDate: onSetPlannedDate,
                onClearPlannedDate: onClearPlannedDate,
                onSetReminder: onSetReminder,
                onClearReminder: onClearReminder,
                onEditTitle: onEditTitle,
                onDelete: onDelete,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            if (!isPreview)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '$quickAddHotkeyLabel = création rapide',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.alwaysOnTop,
    required this.onToggleAlwaysOnTop,
    required this.onHide,
    required this.onClose,
    this.onExpand,
    this.compact = false,
  });

  final bool alwaysOnTop;
  final VoidCallback onToggleAlwaysOnTop;
  final VoidCallback onHide;
  final VoidCallback onClose;
  final VoidCallback? onExpand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = compact ? 18.0 : 20.0;
    final buttonConstraints = compact
        ? const BoxConstraints(minWidth: 32, minHeight: 32)
        : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, compact ? 4 : 8, 4, compact ? 0 : 4),
      child: Row(
        children: [
          Text(
            'MYA',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 14 : null,
            ),
          ),
          const Spacer(),
          if (onExpand != null)
            IconButton(
              tooltip: 'Ouvrir le panneau complet',
              icon: Icon(Icons.open_in_full, size: iconSize),
              visualDensity: compact ? VisualDensity.compact : null,
              constraints: buttonConstraints,
              onPressed: onExpand,
            ),
          IconButton(
            tooltip: alwaysOnTop
                ? 'Désactiver toujours au-dessus'
                : 'Activer toujours au-dessus',
            icon: Icon(
              alwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
              size: iconSize,
            ),
            visualDensity: compact ? VisualDensity.compact : null,
            constraints: buttonConstraints,
            onPressed: onToggleAlwaysOnTop,
          ),
          IconButton(
            tooltip: 'Masquer',
            icon: Icon(Icons.visibility_off_outlined, size: iconSize),
            visualDensity: compact ? VisualDensity.compact : null,
            constraints: buttonConstraints,
            onPressed: onHide,
          ),
          IconButton(
            tooltip: 'Réduire',
            icon: Icon(Icons.close, size: iconSize),
            visualDensity: compact ? VisualDensity.compact : null,
            constraints: buttonConstraints,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
