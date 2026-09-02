import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/data/local/device_settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at startup.',
  );
});

final deviceSettingsStoreProvider = Provider<DeviceSettingsStore>((ref) {
  return DeviceSettingsStore(ref.watch(sharedPreferencesProvider));
});
