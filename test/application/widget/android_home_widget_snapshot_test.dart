import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/widget/android_home_widget_snapshot.dart';
import 'package:mya/core/constants/android_home_widget_keys.dart';
import 'package:mya/domain/entities/task.dart';

void main() {
  final now = DateTime(2026, 10, 13, 12);

  test('pastille ambre si tâche active prévue aujourd\'hui', () {
    final task = Task.createNew(
      id: 'a',
      title: 'Portrait',
      category: TaskCategoryId.next,
      plannedDate: now,
      now: now,
    );

    final snapshot = buildAndroidHomeWidgetSnapshot(
      iconId: 'icon01',
      showSyncBadge: false,
      visibleTasks: [task],
      now: now,
    );

    expect(snapshot.showTodayAttention, isTrue);
    expect(snapshot.todayHeadline, 'Portrait');
  });

  test('pas de pastille si date future', () {
    final task = Task.createNew(
      id: 'b',
      title: 'Demain',
      category: TaskCategoryId.next,
      plannedDate: now.add(const Duration(days: 1)),
      now: now,
    );

    final snapshot = buildAndroidHomeWidgetSnapshot(
      iconId: 'icon01',
      showSyncBadge: true,
      visibleTasks: [task],
      now: now,
    );

    expect(snapshot.showTodayAttention, isFalse);
    expect(snapshot.showSyncBadge, isTrue);
  });

  test('pas de pastille pour tâche terminée', () {
    final task = Task.createNew(
      id: 'c',
      title: 'Fait',
      category: TaskCategoryId.next,
      plannedDate: now,
      now: now,
    ).complete(now: now);

    final snapshot = buildAndroidHomeWidgetSnapshot(
      iconId: 'icon02',
      showSyncBadge: false,
      visibleTasks: [task],
      now: now,
    );

    expect(snapshot.showTodayAttention, isFalse);
    expect(snapshot.iconId, 'icon02');
  });

  test('tronque un titre trop long pour le widget 2×2', () {
    final longTitle = 'A' * (AndroidHomeWidgetKeys.todayHeadlineMaxLength + 5);
    final task = Task.createNew(
      id: 'd',
      title: longTitle,
      category: TaskCategoryId.next,
      plannedDate: now,
      now: now,
    );

    final snapshot = buildAndroidHomeWidgetSnapshot(
      iconId: 'icon01',
      showSyncBadge: false,
      visibleTasks: [task],
      now: now,
    );

    expect(snapshot.todayHeadline.length, AndroidHomeWidgetKeys.todayHeadlineMaxLength);
    expect(snapshot.todayHeadline.endsWith('…'), isTrue);
  });
}
