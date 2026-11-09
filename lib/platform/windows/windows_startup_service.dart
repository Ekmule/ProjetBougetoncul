import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:mya/core/configuration/product_config.dart';
import 'package:mya/platform/startup_service.dart';

/// Démarrage Windows via launch_at_startup (ADR-011).
class WindowsStartupService implements StartupService {
  var _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || !Platform.isWindows) return;

    launchAtStartup.setup(
      appName: ProductConfig.displayName,
      appPath: Platform.resolvedExecutable,
      packageName: ProductConfig.windowsMutexId,
    );
    _initialized = true;
  }

  @override
  Future<bool> isEnabled() async {
    _assertInitialized();
    return launchAtStartup.isEnabled();
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    _assertInitialized();
    if (enabled) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError('WindowsStartupService.initialize() requis.');
    }
  }
}
