import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/sync/sync_status_provider.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/application/widget/android_home_widget_snapshot.dart';
import 'package:mya/core/utils/app_logger.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/platform/android/android_home_widget_bridge.dart';

/// Rafraîchit le widget 1×1 quand sync, icône ou tâches du jour changent (D17a+).
final androidHomeWidgetLifecycleProvider = Provider<void>((ref) {
  if (!Platform.isAndroid) return;

  Future<void> pushWidget() async {
    final sync = ref.read(cloudSyncStatusProvider);
    final iconId = ref
        .read(deviceSettingsStoreProvider)
        .readBubbleSettings()
        .bubbleIconId;

    await AndroidHomeWidgetBridge.update(
      buildAndroidHomeWidgetSnapshot(
        iconId: iconId,
        showSyncBadge: sync.showsConnectedBadge,
        visibleTasks: ref.read(visibleTasksProvider),
      ),
    );
  }

  void schedulePush() {
    unawaited(
      pushWidget().catchError((Object error, StackTrace stackTrace) {
        appLogger.w(
          'Widget Android : mise à jour ignorée',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  ref.listen(cloudSyncStatusProvider, (_, _) => schedulePush());
  ref.listen(taskListStateProvider, (_, _) => schedulePush());

  final resumeObserver = _AndroidHomeWidgetResumeObserver(schedulePush);
  WidgetsBinding.instance.addObserver(resumeObserver);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(resumeObserver);
  });

  Future.microtask(schedulePush);
});

final class _AndroidHomeWidgetResumeObserver with WidgetsBindingObserver {
  _AndroidHomeWidgetResumeObserver(this._onResumed);

  final VoidCallback _onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }
}
