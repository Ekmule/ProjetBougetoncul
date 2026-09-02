import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/core/constants/device_preference_keys.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      DevicePreferenceKeys.bubbleVisible: false,
    });
    preferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        bubbleInitialSettingsProvider.overrideWithValue(
          const BubbleDeviceSettings(bubbleVisible: false),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('ouvrir aperçu rend une pastille masquée visible', () async {
    container.read(bubbleUiProvider.notifier).openPreview();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(bubbleUiProvider);
    expect(state.viewMode, BubbleViewMode.preview);
    expect(state.isVisible, isTrue);
    expect(
      preferences.getBool(DevicePreferenceKeys.bubbleVisible),
      isTrue,
    );
  });

  test('ouvrir panneau rend une pastille masquée visible', () async {
    container.read(bubbleUiProvider.notifier).openPanel();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(bubbleUiProvider);
    expect(state.viewMode, BubbleViewMode.panel);
    expect(state.isVisible, isTrue);
  });

  test('ouvrir création rapide rend la fenêtre visible', () async {
    container.read(bubbleUiProvider.notifier).openQuickAdd();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(bubbleUiProvider);
    expect(state.viewMode, BubbleViewMode.panel);
    expect(state.showQuickAdd, isTrue);
    expect(state.isVisible, isTrue);
  });
}
