import 'dart:io';

/// Helpers multiplateforme sans dépendance Flutter UI.
abstract final class PlatformUtils {
  static bool get isWindows => Platform.isWindows;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || Platform.isLinux || Platform.isMacOS;
}
