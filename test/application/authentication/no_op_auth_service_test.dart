import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/authentication/auth_exception.dart';
import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';

void main() {
  test('NoOpAuthService reste en mode local', () async {
    const service = NoOpAuthService();

    expect(service.isConfigured, isFalse);
    expect(service.currentUser, isNull);
    expect(await service.authStateChanges.first, isNull);

    await expectLater(
      service.signInWithProvider(MyaAuthProvider.google),
      throwsA(isA<AuthNotConfiguredException>()),
    );

    await service.signOut();
  });
}
