import 'package:flutter/foundation.dart';

/// Trace concise des actions en développement, désactivée en release.
abstract final class DebugTrace {
  static void log(String area, String event, [Map<String, Object?>? data]) {
    if (!kDebugMode) return;

    final details = data == null || data.isEmpty
        ? ''
        : ' | ${data.entries.map((entry) => '${entry.key}=${entry.value}').join(' ')}';
    debugPrint('[MYA][$area] $event$details');
  }
}
