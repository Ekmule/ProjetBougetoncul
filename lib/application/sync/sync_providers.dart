import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/sync/sync_service.dart';
import 'package:mya/core/utils/app_logger.dart';
import 'package:mya/data/local/sync_local_store.dart';
import 'package:mya/data/local/sync_metadata_store.dart';
import 'package:mya/data/providers/data_providers.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/data/remote/supabase_task_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isConfigured) return const NoOpSyncService();

  final service = TaskSyncService(
    authService,
    SyncLocalStore(ref.watch(appDatabaseProvider)),
    SyncMetadataStore(ref.watch(sharedPreferencesProvider)),
    SupabaseTaskRemoteDataSource(Supabase.instance.client),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Déclenche la fusion/synchronisation au démarrage et après connexion.
final syncLifecycleProvider = Provider<void>((ref) {
  ref.listen(authUserProvider, (previous, next) {
    if (next.value == null) return;
    unawaited(
      ref.read(syncServiceProvider).syncNow().catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        appLogger.w(
          'Synchronisation automatique impossible',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  });

  final connectivitySubscription = Connectivity().onConnectivityChanged.listen((
    results,
  ) {
    final online = results.any((result) => result != ConnectivityResult.none);
    if (!online || ref.read(authUserProvider).value == null) return;
    unawaited(
      ref.read(syncServiceProvider).syncNow().catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        appLogger.w(
          'Reprise de synchronisation impossible',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  });
  ref.onDispose(connectivitySubscription.cancel);
});
