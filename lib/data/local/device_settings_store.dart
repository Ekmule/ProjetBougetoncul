import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/application/hotkeys/global_hotkey_codec.dart';
import 'package:mya/core/constants/device_preference_keys.dart';
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
      bubbleVisible:
          _prefs.getBool(DevicePreferenceKeys.bubbleVisible) ?? true,
      alwaysOnTop: _prefs.getBool(DevicePreferenceKeys.alwaysOnTop) ?? true,
      startupEnabled:
          _prefs.getBool(DevicePreferenceKeys.startupEnabled) ?? false,
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
