import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/application/hotkeys/global_hotkey_notifier.dart';
import 'package:mya/core/constants/device_preference_keys.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('setHotkey persiste le raccourci', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bubbleInitialSettingsProvider.overrideWithValue(
          const BubbleDeviceSettings(),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(globalHotkeyProvider);
    final custom = HotKey(
      key: PhysicalKeyboardKey.keyA,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );

    await container.read(globalHotkeyProvider.notifier).setHotkey(custom);

    expect(container.read(globalHotkeyProvider).physicalKey, PhysicalKeyboardKey.keyA);
    expect(prefs.getString(DevicePreferenceKeys.globalHotkey), isNotNull);
  });
}
