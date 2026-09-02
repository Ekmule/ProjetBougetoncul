import 'dart:io';

import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/core/configuration/supabase_config.dart';
import 'package:mya/core/constants/auth_constants.dart';
import 'package:mya/data/remote/supabase_auth_service.dart';
import 'package:mya/platform/windows/windows_auth_protocol.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialise Supabase au démarrage si les clés sont présentes (D13).
abstract final class SupabaseBootstrap {
  static Future<AuthService> createAuthService() async {
    if (!SupabaseConfig.isConfigured) {
      return const NoOpAuthService();
    }

    if (Platform.isWindows) {
      WindowsAuthProtocol.register();
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUriPredicate: (uri) {
          if (uri.scheme == AuthConstants.oauthScheme &&
              uri.host == AuthConstants.oauthHost) {
            return true;
          }
          return uri.queryParameters.containsKey('code') ||
              uri.fragment.contains('access_token') ||
              uri.queryParameters.containsKey('error');
        },
      ),
    );

    return SupabaseAuthService();
  }
}
