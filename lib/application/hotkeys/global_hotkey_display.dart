import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// Libellés français pour l'affichage du raccourci global.
abstract final class GlobalHotkeyDisplay {
  static String format(HotKey hotkey) {
    final parts = <String>[
      for (final modifier in hotkey.modifiers ?? []) _modifierLabel(modifier),
      _keyLabel(hotkey.physicalKey),
    ];
    return parts.join('+');
  }

  static String _modifierLabel(HotKeyModifier modifier) {
    return switch (modifier) {
      HotKeyModifier.control => 'Ctrl',
      HotKeyModifier.alt => 'Alt',
      HotKeyModifier.shift => 'Maj',
      HotKeyModifier.meta => 'Win',
      HotKeyModifier.capsLock => 'Verr. maj',
      HotKeyModifier.fn => 'Fn',
    };
  }

  static String _keyLabel(PhysicalKeyboardKey key) {
    if (key == PhysicalKeyboardKey.space) return 'Espace';
    if (key == PhysicalKeyboardKey.enter) return 'Entrée';
    if (key == PhysicalKeyboardKey.tab) return 'Tab';
    if (key == PhysicalKeyboardKey.backspace) return 'Retour';
    if (key == PhysicalKeyboardKey.escape) return 'Échap';

    final debug = key.debugName ?? 'Touche';
    if (debug.startsWith('Key ')) {
      return debug.substring(4);
    }
    return debug;
  }
}
