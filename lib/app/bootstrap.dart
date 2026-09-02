import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_alone/flutter_alone.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/local/database_seed.dart';
import 'package:mya/data/local/device_settings_store.dart';
import 'package:mya/platform/local_notification_service.dart';
import 'package:mya/platform/notification_service.dart';
import 'package:mya/platform/no_op_startup_service.dart';
import 'package:mya/platform/startup_service.dart';
import 'package:mya/platform/window_service.dart';
import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/data/remote/supabase_bootstrap.dart';
import 'package:mya/platform/windows/windows_startup_service.dart';
import 'package:mya/platform/windows/windows_window_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Résultat de l'initialisation au démarrage (services créés avant `runApp`).
class AppBootstrapResult {
  const AppBootstrapResult({
    this.windowService,
    required this.database,
    required this.notificationService,
    required this.sharedPreferences,
    required this.bubbleSettings,
    required this.startupService,
    required this.authService,
  });

  /// Service fenêtre Windows, déjà initialisé en mode pastille.
  final WindowService? windowService;

  /// Base SQLite locale ouverte et prête.
  final AppDatabase database;

  /// Notifications locales initialisées.
  final NotificationService notificationService;

  /// Préférences appareil (shared_preferences).
  final SharedPreferences sharedPreferences;

  /// Paramètres pastille chargés au démarrage.
  final BubbleDeviceSettings bubbleSettings;

  /// Démarrage automatique Windows.
  final StartupService startupService;

  /// Authentification Supabase (NoOp si non configuré).
  final AuthService authService;
}

/// Configure l'environnement Flutter et les services natifs avant l'UI.
class AppBootstrap {
  const AppBootstrap._();

  static Future<AppBootstrapResult> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = AppDatabase();
    await DatabaseSeeder.seedSampleTasksIfEmpty(database);

    final notificationService = LocalNotificationService();
    await notificationService.initialize();

    final sharedPreferences = await SharedPreferences.getInstance();
    final settingsStore = DeviceSettingsStore(sharedPreferences);
    final bubbleSettings = settingsStore.readBubbleSettings();

    final startupService = Platform.isWindows
        ? WindowsStartupService()
        : const NoOpStartupService();
    await startupService.initialize();
    await startupService.setEnabled(bubbleSettings.startupEnabled);

    final authService = await SupabaseBootstrap.createAuthService();

    if (Platform.isWindows) {
      await _ensureSingleInstance();

      final windowService = WindowsWindowController();
      await windowService.initializeBubbleWindow(
        initialPosition: bubbleSettings.position,
        alwaysOnTop: bubbleSettings.alwaysOnTop,
      );

      if (!bubbleSettings.bubbleVisible) {
        await windowService.hide();
      }

      return AppBootstrapResult(
        windowService: windowService,
        database: database,
        notificationService: notificationService,
        sharedPreferences: sharedPreferences,
        bubbleSettings: bubbleSettings,
        startupService: startupService,
        authService: authService,
      );
    }

    return AppBootstrapResult(
      database: database,
      notificationService: notificationService,
      sharedPreferences: sharedPreferences,
      bubbleSettings: bubbleSettings,
      startupService: startupService,
      authService: authService,
    );
  }

  /// Une seule instance de MYA sur Windows (ADR-012).
  static Future<void> _ensureSingleInstance() async {
    final aloneConfig = FlutterAloneConfig.forWindows(
      windowsConfig: const DefaultWindowsMutexConfig(
        packageId: 'com.mya.app',
        appName: 'MYA',
      ),
      windowConfig: const WindowConfig(windowTitle: 'MYA'),
      duplicateCheckConfig: const DuplicateCheckConfig(
        // Un hot restart réexécute main() dans le même processus. Activer le
        // mutex en debug ferait prendre MYA pour sa propre seconde instance.
        enableInDebugMode: false,
      ),
      messageConfig: const EnMessageConfig(),
    );

    if (!await FlutterAlone.instance.checkAndRun(config: aloneConfig)) {
      exit(0);
    }
  }
}
