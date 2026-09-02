import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// Raccourci par défaut — Ctrl+Alt+Espace (ADR-009).
abstract final class GlobalHotkeyDefaults {
  static HotKey get quickAdd => HotKey(
        key: PhysicalKeyboardKey.space,
        modifiers: const [
          HotKeyModifier.control,
          HotKeyModifier.alt,
        ],
        scope: HotKeyScope.system,
      );
}
