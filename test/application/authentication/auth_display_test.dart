import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mya/application/authentication/auth_display.dart';

import 'package:mya/domain/entities/auth_user.dart';

import 'package:mya/domain/entities/mya_auth_provider.dart';

import 'package:mya/l10n/mya_localizations.dart';



void main() {

  group('AuthDisplay', () {

    final l10n = MyaLocalizations.lookupFromLocale(const Locale('fr'));



    test('mode local sans configuration', () {

      expect(

        AuthDisplay.accountSummary(l10n, null, isConfigured: false),

        'Sync cloud non configurée',

      );

      expect(

        AuthDisplay.trayMenuLabel(l10n, null, isConfigured: false),

        'Compte : sync non configurée…',

      );

    });



    test('utilisateur connecté', () {

      const user = AuthUser(id: 'abc', email: 'test@example.com');

      expect(

        AuthDisplay.accountSummary(l10n, user, isConfigured: true),

        'Connecté : test@example.com',

      );

      expect(

        AuthDisplay.trayMenuLabel(l10n, user, isConfigured: true),

        'Compte : test@example.com…',

      );

    });



    test('libellés OAuth', () {

      expect(

        AuthDisplay.providerLabel(l10n, MyaAuthProvider.microsoft),

        'Continuer avec Microsoft',

      );

    });

  });

}


