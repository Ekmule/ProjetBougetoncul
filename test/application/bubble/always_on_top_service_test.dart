import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/bubble/always_on_top_service.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/core/constants/device_preference_keys.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('setEnabled met à jour l état UI et persiste', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bubbleInitialSettingsProvider.overrideWithValue(
          const BubbleDeviceSettings(alwaysOnTop: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(bubbleUiProvider);
    final service = container.read(alwaysOnTopServiceProvider);

    await service.setEnabled(false);

    expect(container.read(bubbleUiProvider).alwaysOnTop, isFalse);
    expect(prefs.getBool(DevicePreferenceKeys.alwaysOnTop), isFalse);
  });

  test('toggle bascule l état', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bubbleInitialSettingsProvider.overrideWithValue(
          const BubbleDeviceSettings(alwaysOnTop: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(bubbleUiProvider);
    final service = container.read(alwaysOnTopServiceProvider);

    await service.toggle();

    expect(container.read(bubbleUiProvider).alwaysOnTop, isTrue);
    expect(prefs.getBool(DevicePreferenceKeys.alwaysOnTop), isTrue);
  });

  test('setEnabled ignore les valeurs identiques', () async {
    SharedPreferences.setMockInitialValues({
      DevicePreferenceKeys.alwaysOnTop: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bubbleInitialSettingsProvider.overrideWithValue(
          const BubbleDeviceSettings(alwaysOnTop: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(bubbleUiProvider);
    final service = container.read(alwaysOnTopServiceProvider);

    await service.setEnabled(true);

    expect(container.read(bubbleUiProvider).alwaysOnTop, isTrue);
  });
}
