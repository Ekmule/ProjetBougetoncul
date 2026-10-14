import 'package:mya/core/constants/android_home_widget_keys.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_display_service.dart';

/// Construit l'état du widget 1×1 (icône, sync, tâches du jour).
AndroidHomeWidgetSnapshot buildAndroidHomeWidgetSnapshot({
  required String iconId,
  required bool showSyncBadge,
  required List<Task> visibleTasks,
  TaskDisplayService displayService = const TaskDisplayService(),
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final grouped = displayService.groupActiveTasks(visibleTasks, clock);
  final todayTasks = grouped[TaskCategoryId.today] ?? const <Task>[];
  final headline = todayTasks.isEmpty
      ? ''
      : _truncateHeadline(todayTasks.first.title);

  return AndroidHomeWidgetSnapshot(
    iconId: BubbleIconCatalog.resolve(iconId).id,
    showSyncBadge: showSyncBadge,
    showTodayAttention: todayTasks.isNotEmpty,
    todayHeadline: headline,
  );
}

String _truncateHeadline(String title) {
  final trimmed = title.trim();
  if (trimmed.length <= AndroidHomeWidgetKeys.todayHeadlineMaxLength) {
    return trimmed;
  }
  return '${trimmed.substring(0, AndroidHomeWidgetKeys.todayHeadlineMaxLength - 1)}…';
}
