import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/core/constants/global_hotkey_defaults.dart';
import 'package:mya/data/providers/device_settings_providers.dart';

/// Raccourci global actif — lu/écrit via shared_preferences (D12).
final globalHotkeyProvider =
    NotifierProvider<GlobalHotkeyNotifier, HotKey>(GlobalHotkeyNotifier.new);

class GlobalHotkeyNotifier extends Notifier<HotKey> {
  @override
  HotKey build() {
    return ref.read(deviceSettingsStoreProvider).readGlobalHotkey();
  }

  Future<void> setHotkey(HotKey hotkey) async {
    await ref.read(deviceSettingsStoreProvider).saveGlobalHotkey(hotkey);
    state = hotkey;
  }

  Future<void> resetToDefault() async {
    await setHotkey(GlobalHotkeyDefaults.quickAdd);
  }
}
