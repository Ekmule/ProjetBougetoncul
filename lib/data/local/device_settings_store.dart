import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/application/hotkeys/global_hotkey_codec.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/constants/device_preference_keys.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistance des paramètres appareil via shared_preferences (ADR-007).
class DeviceSettingsStore {
  DeviceSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  BubbleDeviceSettings readBubbleSettings() {
    final x = _prefs.getDouble(DevicePreferenceKeys.bubbleX);
    final y = _prefs.getDouble(DevicePreferenceKeys.bubbleY);

    return BubbleDeviceSettings(
      position: x != null && y != null ? Offset(x, y) : null,
      bubbleVisible: _prefs.getBool(DevicePreferenceKeys.bubbleVisible) ?? true,
      alwaysOnTop: _prefs.getBool(DevicePreferenceKeys.alwaysOnTop) ?? true,
      startupEnabled:
          _prefs.getBool(DevicePreferenceKeys.startupEnabled) ?? false,
      bubbleSize:
          _prefs.getDouble(DevicePreferenceKeys.bubbleSize) ??
          WindowConstants.defaultBubbleSize,
      bubbleIconId:
          _prefs.getString(DevicePreferenceKeys.bubbleIconId) ??
          BubbleIconCatalog.defaultIconId,
    );
  }

  Future<void> saveBubblePosition(Offset position) async {
    await _prefs.setDouble(DevicePreferenceKeys.bubbleX, position.dx);
    await _prefs.setDouble(DevicePreferenceKeys.bubbleY, position.dy);
  }

  Future<void> saveBubbleVisible(bool visible) async {
    await _prefs.setBool(DevicePreferenceKeys.bubbleVisible, visible);
  }

  Future<void> saveAlwaysOnTop(bool enabled) async {
    await _prefs.setBool(DevicePreferenceKeys.alwaysOnTop, enabled);
  }

  Future<void> saveStartupEnabled(bool enabled) async {
    await _prefs.setBool(DevicePreferenceKeys.startupEnabled, enabled);
  }

  Future<void> saveBubbleSize(double size) async {
    await _prefs.setDouble(DevicePreferenceKeys.bubbleSize, size);
  }

  Future<void> saveBubbleIconId(String iconId) async {
    await _prefs.setString(
      DevicePreferenceKeys.bubbleIconId,
      BubbleIconCatalog.resolve(iconId).id,
    );
  }

  bool hasSelectedBubbleIcon() {
    return _prefs.containsKey(DevicePreferenceKeys.bubbleIconId);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(DevicePreferenceKeys.onboardingCompleted) ?? false;
  }

  Future<void> markOnboardingCompleted() async {
    await _prefs.setBool(DevicePreferenceKeys.onboardingCompleted, true);
  }

  bool hasSeenTrayHint() {
    return _prefs.getBool(DevicePreferenceKeys.trayHintShown) ?? false;
  }

  Future<void> markTrayHintSeen() async {
    await _prefs.setBool(DevicePreferenceKeys.trayHintShown, true);
  }

  Future<void> savePreferCloudSync(bool enabled) async {
    await _prefs.setBool(DevicePreferenceKeys.preferCloudSync, enabled);
  }

  bool readPreferCloudSync() {
    return _prefs.getBool(DevicePreferenceKeys.preferCloudSync) ?? false;
  }

  HotKey readGlobalHotkey() {
    return GlobalHotkeyCodec.decode(
      _prefs.getString(DevicePreferenceKeys.globalHotkey),
    );
  }

  Future<void> saveGlobalHotkey(HotKey hotkey) async {
    await _prefs.setString(
      DevicePreferenceKeys.globalHotkey,
      GlobalHotkeyCodec.encode(hotkey),
    );
  }
}
