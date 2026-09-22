import 'dart:convert';
import 'dart:io';

import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/utils/app_logger.dart';

/// Options choisies pendant l'installation Windows (écrites par Inno Setup).
class InstallOptions {
  const InstallOptions({
    this.startupEnabled = false,
    this.preferCloudSync = false,
    this.bubbleIconId = BubbleIconCatalog.defaultIconId,
  });

  final bool startupEnabled;
  final bool preferCloudSync;
  final String bubbleIconId;

  static InstallOptions? readIfPresent() {
    if (!Platform.isWindows) return null;

    final file = File(_optionsPath);
    if (!file.existsSync()) return null;

    try {
      final map = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final iconRaw = map['bubble_icon'];
      return InstallOptions(
        startupEnabled: map['startup_enabled'] == true,
        preferCloudSync: map['prefer_cloud_sync'] == true,
        bubbleIconId: iconRaw is String && iconRaw.isNotEmpty
            ? BubbleIconCatalog.resolve(iconRaw).id
            : BubbleIconCatalog.defaultIconId,
      );
    } catch (error, stackTrace) {
      appLogger.w(
        'Impossible de lire install_options.json',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Consomme le fichier pour ne l'appliquer qu'une seule fois.
  static Future<void> deleteIfPresent() async {
    if (!Platform.isWindows) return;

    final file = File(_optionsPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String get _optionsPath {
    final appData = Platform.environment['LOCALAPPDATA'];
    if (appData == null || appData.isEmpty) {
      throw StateError('LOCALAPPDATA introuvable.');
    }
    return '$appData\\MYA\\install_options.json';
  }
}
