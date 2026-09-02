import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mya/core/constants/routes.dart';
import 'package:mya/features/floating_bubble/bubble_screen.dart';
import 'package:mya/features/tasks/tasks_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routeur principal MYA.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          // Windows : pastille flottante (prototype P5).
          if (Platform.isWindows) {
            return const BubbleScreen();
          }
          // Android / autres : interface principale plein écran (D4).
          return const TasksScreen();
        },
      ),
    ],
  );
});
