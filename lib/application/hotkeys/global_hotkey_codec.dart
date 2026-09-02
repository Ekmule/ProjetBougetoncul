import 'dart:convert';

import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/core/constants/global_hotkey_defaults.dart';

/// Sérialisation JSON du raccourci global (voir docs/database.md).
abstract final class GlobalHotkeyCodec {
  static HotKey decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return GlobalHotkeyDefaults.quickAdd;
    }

    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return GlobalHotkeyDefaults.quickAdd;
      }
      return HotKey.fromJson(json);
    } catch (_) {
      return GlobalHotkeyDefaults.quickAdd;
    }
  }

  static String encode(HotKey hotkey) {
    return jsonEncode(hotkey.toJson());
  }
}
