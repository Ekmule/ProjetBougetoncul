import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mya/l10n/mya_localizations.dart';

/// Enveloppe MaterialApp pour les tests widget (locale FR par défaut).
Widget testMaterialApp({required Widget home, Locale locale = const Locale('fr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('fr')],
    localizationsDelegates: const [
      MyaLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
