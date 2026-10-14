import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:mya/core/constants/auth_constants.dart';
import 'package:mya/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Relaie le callback OAuth Android vers Supabase Auth (PKCE).
///
/// Non utilisé : le flux mobile passe par [FlutterWebAuth2] (`CallbackActivity`).
/// Un second handler (app_links + ce fichier) rejouait le même `code` au démarrage
/// et provoquait des échecs / fermetures sur certains appareils.
abstract final class AndroidAuthDeepLink {
  static StreamSubscription<Uri>? _subscription;
  static _OAuthLifecycleObserver? _lifecycleObserver;

  static Future<void> register() async {
    if (!Platform.isAndroid) return;

    final appLinks = AppLinks();
    final initial = await appLinks.getInitialLink();
    if (initial != null) {
      await _handleOAuthUri(initial);
    }

    _subscription = appLinks.uriLinkStream.listen(
      _handleOAuthUri,
      onError: (Object error, StackTrace stackTrace) {
        appLogger.w(
          'Deep link OAuth Android invalide',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    _lifecycleObserver = _OAuthLifecycleObserver(appLinks);
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }
  }
}

Future<void> _handleOAuthUri(Uri uri) async {
  if (!_isOAuthCallback(uri)) return;
  try {
    await Supabase.instance.client.auth.getSessionFromUrl(uri);
  } catch (error, stackTrace) {
    appLogger.w(
      'Session OAuth Android impossible',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

bool _isOAuthCallback(Uri uri) {
  if (uri.scheme == AuthConstants.oauthScheme &&
      uri.host == AuthConstants.oauthHost) {
    return true;
  }
  return uri.queryParameters.containsKey('code') ||
      uri.queryParameters.containsKey('error');
}

/// Au retour navigateur, certains launchers ne relaient pas uriLinkStream.
final class _OAuthLifecycleObserver with WidgetsBindingObserver {
  _OAuthLifecycleObserver(this._appLinks);

  final AppLinks _appLinks;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_checkLatestLink());
  }

  Future<void> _checkLatestLink() async {
    try {
      final uri = await _appLinks.getLatestLink();
      if (uri != null) {
        await _handleOAuthUri(uri);
      }
    } catch (error, stackTrace) {
      appLogger.w(
        'Deep link OAuth (resume) ignoré',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
