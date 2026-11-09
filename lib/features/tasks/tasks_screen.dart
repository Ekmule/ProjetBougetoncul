import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/application/reminders/reminder_providers.dart';
import 'package:mya/application/sync/sync_status_provider.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/core/configuration/product_config.dart';
import 'package:mya/domain/services/task_date_service.dart';
import 'package:mya/features/onboarding/android_widget_pin_dialog.dart';
import 'package:mya/features/onboarding/cloud_sign_in_prompt.dart';
import 'package:mya/features/quick_add/quick_add_presenter.dart';
import 'package:mya/features/settings/mobile_settings_sheet.dart';
import 'package:mya/features/shared/widgets/cloud_sync_badge.dart';
import 'package:mya/features/tasks/widgets/task_category_list.dart';
import 'package:mya/features/super_alert/super_alert_dialog.dart';
import 'package:mya/l10n/mya_localizations.dart';
import 'package:mya/platform/android/android_home_widget_bridge.dart';

/// Interface principale MYA — liste globale par catégories (D4).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with WidgetsBindingObserver {
  var _showingSuperAlert = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ProductConfig.supportsCloud) {
        await maybeShowCloudSignInPrompt(context, ref);
      }
      if (!mounted) return;
      await _maybeOfferWidgetPin();
      if (!mounted) return;
      await _maybeShowSuperAlert();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_maybeShowSuperAlert());
    }
  }

  Future<void> _maybeShowSuperAlert() async {
    if (!mounted || _showingSuperAlert) return;
    ref.invalidate(pendingSuperAlertProvider);
    final task = ref.read(pendingSuperAlertProvider);
    if (task == null) return;
    _showingSuperAlert = true;
    try {
      await SuperAlertDialog.show(context, task);
    } finally {
      _showingSuperAlert = false;
    }
  }

  Future<void> _setSuperAlertAndMaybeShow(String id, bool enabled) async {
    final task = await ref
        .read(tasksProvider.notifier)
        .setTaskSuperAlert(id, enabled);
    if (!mounted ||
        !enabled ||
        task == null ||
        _showingSuperAlert ||
        !const TaskDateService().isSuperAlertDue(task, DateTime.now())) {
      return;
    }

    _showingSuperAlert = true;
    try {
      await SuperAlertDialog.show(context, task);
    } finally {
      _showingSuperAlert = false;
    }
  }

  Future<void> _maybeOfferWidgetPin() async {
    if (!Platform.isAndroid || !mounted) return;

    final store = ref.read(deviceSettingsStoreProvider);
    if (store.hasOfferedAndroidWidgetPin()) return;

    await store.markAndroidWidgetPinOffered();
    if (!mounted) return;

    final supported = await AndroidHomeWidgetBridge.isPinSupported();
    if (!supported || !mounted) return;

    await AndroidWidgetPinDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(taskListStateProvider);
    final syncSnapshot = ref.watch(cloudSyncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MYA'),
        centerTitle: false,
        actions: [
          if (ProductConfig.supportsCloud && syncSnapshot.showsConnectedBadge)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: CloudSyncStatusChip(
                  snapshot: syncSnapshot,
                  compact: true,
                ),
              ),
            ),
          IconButton(
            tooltip: context.l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => MobileSettingsSheet.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.quickAddTooltip,
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
              onSetPlannedDate: (id, date, superAlert) => ref
                  .read(tasksProvider.notifier)
                  .setTaskPlannedDate(id, date, superAlert: superAlert),
              onClearPlannedDate: (id) =>
                  ref.read(tasksProvider.notifier).clearTaskPlannedDate(id),
              onSetReminder: (id, when) =>
                  ref.read(tasksProvider.notifier).setTaskReminder(id, when),
              onClearReminder: (id) =>
                  ref.read(tasksProvider.notifier).clearTaskReminder(id),
              onSetSuperAlert: (id, enabled) =>
                  unawaited(_setSuperAlertAndMaybeShow(id, enabled)),
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
