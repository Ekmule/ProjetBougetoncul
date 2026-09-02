import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/domain/entities/auth_user.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';

void main() {
  group('AuthDisplay', () {
    test('mode local sans configuration', () {
      expect(
        AuthDisplay.accountSummary(null, isConfigured: false),
        'Sync cloud non configurée',
      );
      expect(
        AuthDisplay.trayMenuLabel(null, isConfigured: false),
        'Compte : sync non configurée…',
      );
    });

    test('utilisateur connecté', () {
      const user = AuthUser(id: 'abc', email: 'test@example.com');
      expect(
        AuthDisplay.accountSummary(user, isConfigured: true),
        'Connecté : test@example.com',
      );
      expect(
        AuthDisplay.trayMenuLabel(user, isConfigured: true),
        'Compte : test@example.com…',
      );
    });

    test('libellés OAuth', () {
      expect(
        AuthDisplay.providerLabel(MyaAuthProvider.microsoft),
        'Continuer avec Microsoft',
      );
    });
  });
}
