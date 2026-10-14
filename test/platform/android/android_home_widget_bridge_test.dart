import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/widget/android_home_widget_snapshot.dart';
import 'package:mya/core/constants/android_home_widget_keys.dart';

void main() {
  test('buildAndroidHomeWidgetSnapshot normalise icône et badge sync', () {
    const snapshot = AndroidHomeWidgetSnapshot(
      iconId: 'icon02',
      showSyncBadge: true,
      showTodayAttention: false,
      todayHeadline: '',
    );

    final built = buildAndroidHomeWidgetSnapshot(
      iconId: 'icon02',
      showSyncBadge: true,
      visibleTasks: const [],
    );

    expect(built.iconId, snapshot.iconId);
    expect(built.showSyncBadge, isTrue);
    expect(built.showTodayAttention, isFalse);
  });

  test('buildAndroidHomeWidgetSnapshot masque le badge en mode local', () {
    final built = buildAndroidHomeWidgetSnapshot(
      iconId: 'unknown',
      showSyncBadge: false,
      visibleTasks: const [],
    );

    expect(built.iconId, 'icon01');
    expect(built.showSyncBadge, isFalse);
  });
}
