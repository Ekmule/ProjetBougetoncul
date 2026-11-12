import 'package:mya/core/constants/android_home_widget_keys.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_date_service.dart';

/// Construit l'état du widget Android (icône, sync, tâches dues).
AndroidHomeWidgetSnapshot buildAndroidHomeWidgetSnapshot({
  required String iconId,
  required bool showSyncBadge,
  required List<Task> visibleTasks,
  TaskDateService dateService = const TaskDateService(),
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final datedTasks =
      visibleTasks
          .where((task) => task.isActive && task.plannedDate != null)
          .toList()
        ..sort((a, b) => a.plannedDate!.compareTo(b.plannedDate!));
  final attentionTasks = datedTasks
      .where(
        (task) =>
            dateService.isDueToday(task, clock) ||
            dateService.isOverdue(task, clock),
      )
      .toList();
  final headline = datedTasks.isEmpty
      ? ''
      : _truncateHeadline(datedTasks.first.title);

  return AndroidHomeWidgetSnapshot(
    iconId: BubbleIconCatalog.resolve(iconId).id,
    showSyncBadge: showSyncBadge,
    showTodayAttention: attentionTasks.isNotEmpty,
    todayHeadline: headline,
    attentionDate: datedTasks.isEmpty
        ? ''
        : _isoDate(datedTasks.first.plannedDate!),
  );
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _truncateHeadline(String title) {
  final trimmed = title.trim();
  if (trimmed.length <= AndroidHomeWidgetKeys.todayHeadlineMaxLength) {
    return trimmed;
  }
  return '${trimmed.substring(0, AndroidHomeWidgetKeys.todayHeadlineMaxLength - 1)}…';
}
