import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/app/router.dart';
import 'package:mya/app/theme.dart';

/// Racine de l'interface Flutter MYA.
class MyaApp extends ConsumerWidget {
  const MyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'MYA',
      debugShowCheckedModeBanner: false,
      theme: MyaTheme.dark(),
      routerConfig: router,
    );
  }
}
