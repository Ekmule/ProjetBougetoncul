import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/app/app.dart';
import 'package:mya/app/bootstrap.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/data/providers/data_providers.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/platform/platform_providers.dart';

/// Point d'entrée de MYA.
Future<void> main() async {
  final bootstrap = await AppBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(bootstrap.database.close);
          return bootstrap.database;
        }),
        if (bootstrap.windowService != null)
          windowServiceProvider.overrideWithValue(bootstrap.windowService!),
        notificationServiceProvider.overrideWithValue(
          bootstrap.notificationService,
        ),
        sharedPreferencesProvider.overrideWithValue(
          bootstrap.sharedPreferences,
        ),
        bubbleInitialSettingsProvider.overrideWithValue(
          bootstrap.bubbleSettings,
        ),
        startupServiceProvider.overrideWithValue(bootstrap.startupService),
        authServiceProvider.overrideWithValue(bootstrap.authService),
      ],
      child: const MyaApp(),
    ),
  );
}
