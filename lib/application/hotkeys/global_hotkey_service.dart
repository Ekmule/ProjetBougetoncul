import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/application/hotkeys/global_hotkey_display.dart';
import 'package:mya/application/hotkeys/global_hotkey_notifier.dart';
import 'package:mya/platform/platform_providers.dart';

/// Enregistre le raccourci système de création rapide (D12).
class GlobalHotkeyService {
  const GlobalHotkeyService(this._ref);

  final Ref _ref;

  HotKey get currentHotkey => _ref.read(globalHotkeyProvider);

  String get displayLabel => GlobalHotkeyDisplay.format(currentHotkey);

  Future<void> registerQuickAddHandler(void Function() onTriggered) async {
    await _ref.read(hotkeyServiceProvider).registerQuickAdd(
          hotKey: currentHotkey,
          onTriggered: onTriggered,
        );
  }

  /// Valide qu'un raccourci est utilisable (au moins une touche + modificateur).
  bool isValid(HotKey hotkey) {
    final modifiers = hotkey.modifiers ?? const [];
    return modifiers.isNotEmpty;
  }
}

final globalHotkeyServiceProvider = Provider<GlobalHotkeyService>((ref) {
  return GlobalHotkeyService(ref);
});
