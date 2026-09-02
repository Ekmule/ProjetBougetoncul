import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/application/hotkeys/global_hotkey_codec.dart';
import 'package:mya/application/hotkeys/global_hotkey_display.dart';
import 'package:mya/core/constants/global_hotkey_defaults.dart';

void main() {
  test('decode retourne le défaut si JSON absent', () {
    final hotkey = GlobalHotkeyCodec.decode(null);
    expect(hotkey.physicalKey, PhysicalKeyboardKey.space);
    expect(hotkey.modifiers, contains(HotKeyModifier.control));
  });

  test('encode/decode round-trip', () {
    final custom = HotKey(
      key: PhysicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );

    final decoded = GlobalHotkeyCodec.decode(GlobalHotkeyCodec.encode(custom));

    expect(decoded.physicalKey, PhysicalKeyboardKey.keyQ);
    expect(decoded.modifiers, contains(HotKeyModifier.shift));
  });

  test('format affiche Ctrl+Alt+Espace par défaut', () {
    final label = GlobalHotkeyDisplay.format(GlobalHotkeyDefaults.quickAdd);
    expect(label, 'Ctrl+Alt+Espace');
  });
}
