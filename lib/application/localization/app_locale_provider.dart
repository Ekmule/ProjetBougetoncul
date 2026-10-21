import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/l10n/app_locale_code.dart';

/// Locale UI active (phase A).
final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final store = ref.watch(deviceSettingsStoreProvider);
    return store.readAppLocale().toFlutterLocale();
  }

  Future<void> setLocale(AppLocaleCode code) async {
    await ref.read(deviceSettingsStoreProvider).saveAppLocale(code);
    state = code.toFlutterLocale();
  }
}
