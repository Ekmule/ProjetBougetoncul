import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/app/router.dart';
import 'package:mya/app/theme.dart';
import 'package:mya/application/localization/app_locale_provider.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/mya_localizations.dart';
import 'package:mya/application/sync/sync_providers.dart';
import 'package:mya/application/updates/update_providers.dart';
import 'package:mya/application/widget/android_home_widget_providers.dart';

/// Racine de l'interface Flutter MYA.
class MyaApp extends ConsumerWidget {
  const MyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncLifecycleProvider);
    ref.watch(updateLifecycleProvider);
    ref.watch(androidHomeWidgetLifecycleProvider);
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'MYA',
      debugShowCheckedModeBanner: false,
      theme: MyaTheme.dark(),
      locale: locale,
      supportedLocales: [
        AppLocaleCode.en.toFlutterLocale(),
        AppLocaleCode.fr.toFlutterLocale(),
      ],
      localizationsDelegates: const [
        MyaLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
