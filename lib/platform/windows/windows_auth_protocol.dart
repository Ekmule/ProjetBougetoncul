import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:mya/core/constants/auth_constants.dart';
import 'package:win32/win32.dart';

/// Enregistre le schéma URI Windows pour le callback OAuth (D13).
abstract final class WindowsAuthProtocol {
  static void register() {
    if (!Platform.isWindows) return;

    final scheme = AuthConstants.oauthScheme;
    final prefix = 'SOFTWARE\\Classes\\$scheme';
    final capitalized = scheme[0].toUpperCase() + scheme.substring(1);
    final executable = Platform.resolvedExecutable.replaceAll(r'"', r'\"');
    final command = '"$executable" "%1"';

    _regCreateStringKey(HKEY_CURRENT_USER, prefix, '', 'URL:$capitalized');
    _regCreateStringKey(HKEY_CURRENT_USER, prefix, 'URL Protocol', '');
    _regCreateStringKey(
      HKEY_CURRENT_USER,
      '$prefix\\shell\\open\\command',
      '',
      command,
    );
  }

  static int _regCreateStringKey(
    int hKey,
    String key,
    String valueName,
    String data,
  ) {
    final txtKey = key.toNativeUtf16();
    final txtValue = valueName.toNativeUtf16();
    final txtData = data.toNativeUtf16();
    try {
      return RegSetKeyValue(
        hKey,
        txtKey,
        txtValue,
        REG_SZ,
        txtData,
        txtData.length * 2 + 2,
      );
    } finally {
      free(txtKey);
      free(txtValue);
      free(txtData);
    }
  }
}
