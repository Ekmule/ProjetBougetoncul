import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/app/router.dart';
import 'package:mya/app/theme.dart';
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

    return MaterialApp.router(
      title: 'MYA',
      debugShowCheckedModeBanner: false,
      theme: MyaTheme.dark(),
      routerConfig: router,
    );
  }
}
