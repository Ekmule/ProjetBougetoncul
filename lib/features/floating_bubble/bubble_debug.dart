import 'package:mya/core/utils/debug_trace.dart';

/// Logs de diagnostic pastille Windows (survol, resize, blur…).
abstract final class BubbleDebug {
  static void log(String event, [Map<String, Object?>? data]) {
    DebugTrace.log('bubble', event, data);
  }
}
