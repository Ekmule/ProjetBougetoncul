import 'package:flutter_test/flutter_test.dart';
import 'package:mya/core/constants/device_preference_keys.dart';
import 'package:mya/data/local/device_settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('readBubbleSettings restaure position et préférences', () async {
    SharedPreferences.setMockInitialValues({
      DevicePreferenceKeys.bubbleX: 120.5,
      DevicePreferenceKeys.bubbleY: 340.0,
      DevicePreferenceKeys.bubbleVisible: false,
      DevicePreferenceKeys.alwaysOnTop: false,
      DevicePreferenceKeys.startupEnabled: true,
      DevicePreferenceKeys.bubbleSize: 72.0,
    });

    final prefs = await SharedPreferences.getInstance();
    final store = DeviceSettingsStore(prefs);
    final settings = store.readBubbleSettings();

    expect(settings.position, const Offset(120.5, 340.0));
    expect(settings.bubbleVisible, isFalse);
    expect(settings.alwaysOnTop, isFalse);
    expect(settings.startupEnabled, isTrue);
    expect(settings.bubbleSize, 72);
  });

  test('saveBubblePosition persiste les coordonnées', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = DeviceSettingsStore(prefs);

    await store.saveBubblePosition(const Offset(50, 75));

    expect(prefs.getDouble(DevicePreferenceKeys.bubbleX), 50);
    expect(prefs.getDouble(DevicePreferenceKeys.bubbleY), 75);
  });

  test('saveBubbleIconId et onboarding sont persistés', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = DeviceSettingsStore(prefs);

    await store.saveBubbleIconId('icon03');
    expect(store.readBubbleSettings().bubbleIconId, 'icon03');

    expect(store.isOnboardingCompleted(), isFalse);
    await store.markOnboardingCompleted();
    expect(store.isOnboardingCompleted(), isTrue);
  });
}
