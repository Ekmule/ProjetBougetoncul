import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/bubble/always_on_top_service.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/features/floating_bubble/bubble_debug.dart';
import 'package:mya/features/floating_bubble/widgets/bubble_button.dart';
import 'package:mya/features/floating_bubble/widgets/task_panel.dart';
import 'package:mya/features/quick_add/quick_add_presenter.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/hotkeys/global_hotkey_notifier.dart';
import 'package:mya/application/hotkeys/global_hotkey_service.dart';
import 'package:mya/features/settings/widgets/auth_settings_dialog.dart';
import 'package:mya/features/settings/widgets/hotkey_settings_dialog.dart';
import 'package:mya/platform/platform_providers.dart';
import 'package:mya/platform/tray_service.dart';
import 'package:mya/platform/window_service.dart';
import 'package:mya/platform/windows/windows_tray_service.dart';
import 'package:window_manager/window_manager.dart';

/// Écran principal Windows : pastille production + tray (D10–D12).
class BubbleScreen extends ConsumerStatefulWidget {
  const BubbleScreen({super.key});

  @override
  ConsumerState<BubbleScreen> createState() => _BubbleScreenState();
}

class _BubbleScreenState extends ConsumerState<BubbleScreen>
    with WindowListener {
  late final WindowService _windowService;
  late final WindowsTrayService _trayService;
  late final _BubbleTrayActions _trayActions;

  Timer? _hoverTimer;
  Timer? _collapseTimer;
  var _isApplyingViewMode = false;
  DateTime? _previewHoverGraceUntil;

  @override
  void initState() {
    super.initState();
    _windowService = ref.read(windowServiceProvider);
    _trayActions = _BubbleTrayActions(
      ref: ref,
      onConfigureHotkey: _showHotkeySettingsDialog,
      onConfigureAccount: _showAuthSettingsDialog,
    );
    _trayService = WindowsTrayService(_trayActions, _readTrayMenuState);
    windowManager.addListener(this);
    _registerHotkey();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _trayService.initialize();
      await _syncWindowToViewMode();
    });
  }

  Future<void> _syncWindowToViewMode() async {
    final ui = ref.read(bubbleUiProvider);
    if (!ui.isVisible) return;

    await _windowService.applyViewMode(
      isBubble: ui.viewMode == BubbleViewMode.bubble,
      isPreview: ui.viewMode == BubbleViewMode.preview,
      isPanel: ui.viewMode == BubbleViewMode.panel,
    );
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _collapseTimer?.cancel();
    windowManager.removeListener(this);
    unawaited(_trayService.dispose());
    super.dispose();
  }

  /// Clic en dehors — réduit le panneau complet (ADR-018, pas l'aperçu survol).
  @override
  void onWindowBlur() {
    if (!mounted || _isApplyingViewMode) {
      BubbleDebug.log('blur ignored', {
        'mounted': mounted,
        'applying': _isApplyingViewMode,
      });
      return;
    }

    final mode = ref.read(bubbleUiProvider).viewMode;
    BubbleDebug.log('blur', {'mode': mode.name});
    if (mode == BubbleViewMode.panel) {
      unawaited(_collapseToBubble());
    }
  }

  Future<void> _toggleAlwaysOnTop() async {
    await ref.read(alwaysOnTopServiceProvider).toggle();
    await _refreshTrayMenu();
  }

  TrayMenuState _readTrayMenuState() {
    final ui = ref.read(bubbleUiProvider);
    final settings = ref.read(deviceSettingsStoreProvider).readBubbleSettings();
    final authUser = ref.read(authUserProvider).value;
    final authConfigured = ref.read(authConfiguredProvider);
    return TrayMenuState(
      bubbleVisible: ui.isVisible,
      alwaysOnTop: ui.alwaysOnTop,
      startupEnabled: settings.startupEnabled,
      hotkeyLabel: ref.read(globalHotkeyServiceProvider).displayLabel,
      authLabel: AuthDisplay.trayMenuLabel(
        authUser,
        isConfigured: authConfigured,
      ),
    );
  }

  Future<void> _registerHotkey() async {
    ref.read(globalHotkeyProvider);
    await ref.read(globalHotkeyServiceProvider).registerQuickAddHandler(() {
      if (!mounted) return;
      ref.read(bubbleUiProvider.notifier).openQuickAdd();
      _showQuickAddDialog();
    });
  }

  Future<void> _showAuthSettingsDialog() async {
    if (!mounted) return;
    final changed = await AuthSettingsDialog.show(context);
    if (changed == true && mounted) {
      await _refreshTrayMenu();
    }
  }

  Future<void> _showHotkeySettingsDialog() async {
    if (!mounted) return;
    final saved = await HotkeySettingsDialog.show(context);
    if (saved == true && mounted) {
      await _registerHotkey();
      await _refreshTrayMenu();
    }
  }

  Future<void> _refreshTrayMenu() async {
    await _trayService.updateMenu();
  }

  void _onHoverEnter() {
    _collapseTimer?.cancel();
    BubbleDebug.log('hover enter', {
      'mode': ref.read(bubbleUiProvider).viewMode.name,
      'applying': _isApplyingViewMode,
    });

    if (_isApplyingViewMode) return;

    final mode = ref.read(bubbleUiProvider).viewMode;
    if (mode != BubbleViewMode.bubble) return;

    _hoverTimer?.cancel();
    _hoverTimer = Timer(WindowConstants.hoverDelay, () {
      BubbleDebug.log('hover delay elapsed → open preview');
      unawaited(_openPreviewFromHover());
    });
  }

  Future<void> _openPreviewFromHover() async {
    if (!mounted) return;
    if (ref.read(bubbleUiProvider).viewMode != BubbleViewMode.bubble) return;

    BubbleDebug.log('open preview start');
    _isApplyingViewMode = true;
    try {
      await _windowService.applyViewMode(
        isBubble: false,
        isPreview: true,
        isPanel: false,
      );
      if (!mounted) return;
      ref.read(bubbleUiProvider.notifier).openPreview();
      _previewHoverGraceUntil = DateTime.now().add(
        const Duration(milliseconds: 800),
      );
      BubbleDebug.log('open preview done', {
        'graceUntil': _previewHoverGraceUntil!.toIso8601String(),
      });
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (mounted) _isApplyingViewMode = false;
    }
  }

  void _onHoverExit() {
    final mode = ref.read(bubbleUiProvider).viewMode;
    final inGrace =
        _previewHoverGraceUntil != null &&
        DateTime.now().isBefore(_previewHoverGraceUntil!);

    BubbleDebug.log('hover exit', {
      'mode': mode.name,
      'applying': _isApplyingViewMode,
      'inGrace': inGrace,
    });

    if (_isApplyingViewMode) return;
    if (inGrace) {
      BubbleDebug.log('hover exit ignored (grace period)');
      return;
    }

    _hoverTimer?.cancel();
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(milliseconds: 500), () {
      BubbleDebug.log('collapse timer elapsed');
      unawaited(_collapsePreviewFromHover());
    });
  }

  Future<void> _collapsePreviewFromHover() async {
    if (!mounted || _isApplyingViewMode) return;
    if (ref.read(bubbleUiProvider).viewMode != BubbleViewMode.preview) return;

    BubbleDebug.log('collapse preview start');
    _previewHoverGraceUntil = null;
    _isApplyingViewMode = true;
    try {
      await _windowService.applyViewMode(
        isBubble: true,
        isPreview: false,
        isPanel: false,
      );
      if (!mounted) return;
      ref.read(bubbleUiProvider.notifier).collapseToBubble();
      BubbleDebug.log('collapse preview done');
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (mounted) _isApplyingViewMode = false;
    }
  }

  void _onBubbleTap() {
    unawaited(_openFullPanel());
  }

  Future<void> _openFullPanel() async {
    if (_isApplyingViewMode) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted || _isApplyingViewMode) return;
    }

    BubbleDebug.log('open panel start');
    _hoverTimer?.cancel();
    _collapseTimer?.cancel();
    _previewHoverGraceUntil = null;
    _isApplyingViewMode = true;
    try {
      ref.read(bubbleUiProvider.notifier).openPanel();
      await _windowService.applyViewMode(
        isBubble: false,
        isPreview: false,
        isPanel: true,
      );
      BubbleDebug.log('open panel done');
    } finally {
      _isApplyingViewMode = false;
    }
  }

  Future<void> _collapseToBubble() async {
    if (!mounted || _isApplyingViewMode) return;

    BubbleDebug.log('collapse to bubble start');
    _hoverTimer?.cancel();
    _collapseTimer?.cancel();
    _previewHoverGraceUntil = null;
    _isApplyingViewMode = true;
    try {
      ref.read(bubbleUiProvider.notifier).collapseToBubble();
      await _windowService.applyViewMode(
        isBubble: true,
        isPreview: false,
        isPanel: false,
      );
      BubbleDebug.log('collapse to bubble done');
    } finally {
      _isApplyingViewMode = false;
    }
  }

  void _onBubbleDoubleTap() {
    unawaited(_toggleAlwaysOnTop());
  }

  Future<void> _onPanUpdate(DragUpdateDetails details) async {
    await _windowService.moveBy(details.delta);
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    await _windowService.snapToEdgeIfNeeded();
    final position = await _windowService.getPosition();
    await ref.read(deviceSettingsStoreProvider).saveBubblePosition(position);
  }

  Future<void> _showQuickAddDialog() async {
    if (!mounted) return;
    ref.read(bubbleUiProvider.notifier).openQuickAdd();
    await QuickAddPresenter.showQuickAddDialog(context, ref);
    ref.read(bubbleUiProvider.notifier).closeQuickAdd();
  }

  @override
  Widget build(BuildContext context) {
    final hotkeyLabel = ref.watch(globalHotkeyServiceProvider).displayLabel;

    ref.listen(authUserProvider, (previous, next) async {
      if (previous?.value?.id != next.value?.id) {
        await _refreshTrayMenu();
      }
    });

    ref.listen(bubbleUiProvider, (previous, next) async {
      BubbleDebug.log('ui mode change', {
        'from': previous?.viewMode.name,
        'to': next.viewMode.name,
        'visible': next.isVisible,
      });

      if (previous?.alwaysOnTop != next.alwaysOnTop ||
          previous?.isVisible != next.isVisible) {
        await _refreshTrayMenu();
      }

      if (!next.isVisible) {
        await _windowService.hide();
        return;
      }

      if (_isApplyingViewMode) return;

      await _windowService.show();
      _isApplyingViewMode = true;
      try {
        await _windowService.applyViewMode(
          isBubble: next.viewMode == BubbleViewMode.bubble,
          isPreview: next.viewMode == BubbleViewMode.preview,
          isPanel: next.viewMode == BubbleViewMode.panel,
        );
        await _windowService.setAlwaysOnTop(next.alwaysOnTop);
      } finally {
        _isApplyingViewMode = false;
      }
    });

    final uiState = ref.watch(bubbleUiProvider);
    final listState = ref.watch(taskListStateProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pendant le redimensionnement natif, la fenêtre peut encore faire 64 px
        // alors que le mode UI est déjà « preview » — on garde la pastille visible.
        final windowIsBubbleSized =
            constraints.maxWidth <= WindowConstants.bubbleSize + 4 &&
            constraints.maxHeight <= WindowConstants.bubbleSize + 4;
        final windowStillCompact =
            constraints.maxWidth < WindowConstants.previewWidth - 24 ||
            constraints.maxHeight < WindowConstants.previewHeight - 24;

        final showBubble =
            uiState.viewMode == BubbleViewMode.bubble || windowStillCompact;
        final showPreview =
            uiState.viewMode == BubbleViewMode.preview && !windowStillCompact;
        final showPanel =
            uiState.viewMode == BubbleViewMode.panel && !windowStillCompact;

        return Scaffold(
          backgroundColor: windowIsBubbleSized
              ? WindowConstants.bubbleColor
              : const Color(0xFF1E1E1E),
          body: MouseRegion(
            onEnter: (_) => _onHoverEnter(),
            onExit: (_) => _onHoverExit(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (showBubble)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: _onBubbleTap,
                      onDoubleTap: _onBubbleDoubleTap,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: BubbleButton(alwaysOnTop: uiState.alwaysOnTop),
                    ),
                  ),
                if (showPreview)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => unawaited(_openFullPanel()),
                      child: TaskPanel(
                        groupedTasks: listState.grouped,
                        completedTasks: listState.completed,
                        isPreview: true,
                        alwaysOnTop: uiState.alwaysOnTop,
                        onExpand: () => unawaited(_openFullPanel()),
                        onClose: () => unawaited(_collapseToBubble()),
                        onComplete: (id) =>
                            ref.read(tasksProvider.notifier).completeTask(id),
                        onReopen: (id) =>
                            ref.read(tasksProvider.notifier).reopenTask(id),
                        onMoveCategory: (id, category) => ref
                            .read(tasksProvider.notifier)
                            .moveTaskToCategory(id, category),
                        onSetPlannedDate: (id, date) => ref
                            .read(tasksProvider.notifier)
                            .setTaskPlannedDate(id, date),
                        onClearPlannedDate: (id) => ref
                            .read(tasksProvider.notifier)
                            .clearTaskPlannedDate(id),
                        onSetReminder: (id, when) => ref
                            .read(tasksProvider.notifier)
                            .setTaskReminder(id, when),
                        onClearReminder: (id) => ref
                            .read(tasksProvider.notifier)
                            .clearTaskReminder(id),
                        onToggleAlwaysOnTop: () =>
                            unawaited(_toggleAlwaysOnTop()),
                        onHide: () {
                          ref.read(bubbleUiProvider.notifier).hideBubble();
                          unawaited(_refreshTrayMenu());
                        },
                        quickAddHotkeyLabel: hotkeyLabel,
                      ),
                    ),
                  ),
                if (showPanel)
                  Positioned.fill(
                    child: TaskPanel(
                      groupedTasks: listState.grouped,
                      completedTasks: listState.completed,
                      isPreview: false,
                      alwaysOnTop: uiState.alwaysOnTop,
                      onClose: () => unawaited(_collapseToBubble()),
                      onComplete: (id) =>
                          ref.read(tasksProvider.notifier).completeTask(id),
                      onReopen: (id) =>
                          ref.read(tasksProvider.notifier).reopenTask(id),
                      onMoveCategory: (id, category) => ref
                          .read(tasksProvider.notifier)
                          .moveTaskToCategory(id, category),
                      onSetPlannedDate: (id, date) => ref
                          .read(tasksProvider.notifier)
                          .setTaskPlannedDate(id, date),
                      onClearPlannedDate: (id) => ref
                          .read(tasksProvider.notifier)
                          .clearTaskPlannedDate(id),
                      onSetReminder: (id, when) => ref
                          .read(tasksProvider.notifier)
                          .setTaskReminder(id, when),
                      onClearReminder: (id) => ref
                          .read(tasksProvider.notifier)
                          .clearTaskReminder(id),
                      onEditTitle: (id, title) => ref
                          .read(tasksProvider.notifier)
                          .updateTaskTitle(id, title),
                      onDelete: (id) =>
                          ref.read(tasksProvider.notifier).deleteTask(id),
                      onToggleAlwaysOnTop: () =>
                          unawaited(_toggleAlwaysOnTop()),
                      onHide: () {
                        ref.read(bubbleUiProvider.notifier).hideBubble();
                        unawaited(_refreshTrayMenu());
                      },
                      quickAddHotkeyLabel: hotkeyLabel,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BubbleTrayActions implements TrayActions {
  _BubbleTrayActions({
    required this.ref,
    required this.onConfigureHotkey,
    required this.onConfigureAccount,
  });

  final WidgetRef ref;
  final Future<void> Function() onConfigureHotkey;
  final Future<void> Function() onConfigureAccount;

  @override
  void openMya() {
    ref.read(bubbleUiProvider.notifier).showBubble();
    ref.read(bubbleUiProvider.notifier).openPanel();
  }

  @override
  void toggleBubbleVisible() {
    final notifier = ref.read(bubbleUiProvider.notifier);
    final visible = ref.read(bubbleUiProvider).isVisible;
    if (visible) {
      notifier.hideBubble();
    } else {
      notifier.showBubble();
      notifier.openPanel();
    }
  }

  @override
  void toggleAlwaysOnTop() {
    unawaited(ref.read(alwaysOnTopServiceProvider).toggle());
  }

  @override
  void configureHotkey() {
    unawaited(onConfigureHotkey());
  }

  @override
  void configureAccount() {
    unawaited(onConfigureAccount());
  }

  @override
  Future<void> toggleStartupEnabled() async {
    final store = ref.read(deviceSettingsStoreProvider);
    final current = store.readBubbleSettings().startupEnabled;
    final next = !current;
    await store.saveStartupEnabled(next);
    await ref.read(startupServiceProvider).setEnabled(next);
  }

  @override
  Future<void> quit() async {
    await windowManager.destroy();
  }
}
