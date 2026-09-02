import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/platform/hotkey_service.dart';
import 'package:mya/platform/no_op_notification_service.dart';
import 'package:mya/platform/no_op_startup_service.dart';
import 'package:mya/platform/notification_service.dart';
import 'package:mya/platform/startup_service.dart';
import 'package:mya/platform/window_service.dart';
import 'package:mya/platform/windows/windows_hotkey_controller.dart';
import 'package:mya/platform/windows/windows_startup_service.dart';
import 'package:mya/platform/windows/windows_window_controller.dart';

/// Service fenêtre — surchargé au démarrage avec l'instance déjà initialisée.
final windowServiceProvider = Provider<WindowService>((ref) {
  if (Platform.isWindows) {
    return WindowsWindowController();
  }
  throw UnsupportedError('WindowService is only available on Windows.');
});

/// Raccourcis globaux Windows (Ctrl+Alt+Space).
final hotkeyServiceProvider = Provider<HotkeyService>((ref) {
  final service =
      Platform.isWindows ? WindowsHotkeyController() : const NoOpHotkeyService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Notifications locales — surchargé au démarrage après [initialize].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return const NoOpNotificationService();
});

/// Démarrage automatique Windows — surchargé au bootstrap.
final startupServiceProvider = Provider<StartupService>((ref) {
  if (Platform.isWindows) {
    return WindowsStartupService();
  }
  return const NoOpStartupService();
});
