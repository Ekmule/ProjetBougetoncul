import 'dart:async';

import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/application/sync/sync_conflict_resolver.dart';
import 'package:mya/core/utils/app_logger.dart';
import 'package:mya/data/local/sync_local_store.dart';
import 'package:mya/data/local/sync_metadata_store.dart';
import 'package:mya/data/remote/task_remote_data_source.dart';
import 'package:mya/domain/entities/task.dart';

/// Synchronisation bidirectionnelle locale ↔ Supabase.
abstract class SyncService {
  Future<void> syncNow();

  void dispose();

  /// Indique si une synchronisation est en cours.
  bool get isSyncing;

  /// Flux réactif de l'activité de synchronisation.
  Stream<bool> get syncingStream;
}

class NoOpSyncService implements SyncService {
  const NoOpSyncService();

  @override
  Future<void> syncNow() async {}

  @override
  void dispose() {}

  @override
  bool get isSyncing => false;

  @override
  Stream<bool> get syncingStream => const Stream<bool>.empty();
}

class TaskSyncService implements SyncService {
  TaskSyncService(
    this._authService,
    this._localStore,
    this._metadataStore,
    this._remote, [
    this._conflictResolver = const SyncConflictResolver(),
  ]);

  final AuthService _authService;
  final SyncLocalStore _localStore;
  final SyncMetadataStore _metadataStore;
  final TaskRemoteDataSource _remote;
  final SyncConflictResolver _conflictResolver;

  Future<void>? _runningSync;
  var _syncRequested = false;
  Timer? _retryTimer;
  var _retryAttempt = 0;
  var _disposed = false;
  var _isSyncing = false;
  final _syncingController = StreamController<bool>.broadcast();

  @override
  bool get isSyncing => _isSyncing;

  @override
  Stream<bool> get syncingStream => _syncingController.stream;

  @override
  Future<void> syncNow() {
    if (_disposed) return Future.value();
    _syncRequested = true;
    final running = _runningSync;
    if (running != null) return running;

    late final Future<void> future;
    future = _runRequestedSyncs().whenComplete(() {
      if (identical(_runningSync, future)) {
        _runningSync = null;
        _setSyncing(false);
      }
    });
    _runningSync = future;
    _setSyncing(true);
    return future;
  }

  void _setSyncing(bool value) {
    if (_isSyncing == value) return;
    _isSyncing = value;
    if (!_syncingController.isClosed) {
      _syncingController.add(value);
    }
  }

  Future<void> _runRequestedSyncs() async {
    do {
      _syncRequested = false;
      try {
        await _synchronize();
      } on _SessionChanged {
        _syncRequested = true;
      } catch (_) {
        await _scheduleRetryIfUseful();
        rethrow;
      }
    } while (_syncRequested);
    _cancelRetry();
  }

  Future<void> _synchronize() async {
    final user = _authService.currentUser;
    if (user == null) return;
    await _localStore.recoverInterruptedOperations();
    _ensureSession(user.id);
    final claimedTaskIds = await _localStore.claimUnownedTasks(user.id);
    try {
      _ensureSession(user.id);
    } on _SessionChanged {
      await _localStore.releaseClaimedTasks(claimedTaskIds, user.id);
      rethrow;
    }

    if (!_metadataStore.isInitialMergeCompleted(user.id)) {
      await _performInitialMerge(user.id);
    } else {
      final queueSucceeded = await _processQueue(user.id);
      if (!queueSucceeded && !_syncRequested) {
        throw StateError(
          'Synchronisation incomplète : envoi cloud impossible.',
        );
      }
      _ensureSession(user.id);
      await _pullRemoteChanges(user.id);
    }
  }

  Future<void> _performInitialMerge(String userId) async {
    final localTasks = await _localStore.getTasksForUser(userId);
    for (final local in localTasks) {
      await _localStore.ensureTaskQueued(local);
    }

    final queueSucceeded = await _processQueue(userId);
    if (!queueSucceeded) {
      throw StateError('Fusion initiale incomplète : envoi cloud impossible.');
    }
    _ensureSession(userId);
    await _pullRemoteChanges(userId);
    _ensureSession(userId);
    await _metadataStore.markInitialMergeCompleted(userId);
    appLogger.i('Fusion initiale Supabase terminée');
  }

  Future<bool> _processQueue(String userId) async {
    final operations = await _localStore.getRetryableOperations();
    var succeeded = true;

    for (final operation in operations) {
      _ensureSession(userId);
      await _localStore.markOperationInProgress(operation.id);
      try {
        final task = await _localStore.findTask(operation.entityId);
        if (task == null) {
          await _localStore.markOperationSent(operation.id);
          continue;
        }
        if (task.userId != null && task.userId != userId) {
          await _localStore.markOperationPending(operation.id);
          continue;
        }

        final canonical = await _remote.upsert(task, userId: userId);
        _ensureSession(userId);
        await _localStore.completeOperation(operation.id, canonical);
      } on _SessionChanged {
        await _localStore.markOperationPending(operation.id);
        rethrow;
      } catch (error, stackTrace) {
        succeeded = false;
        await _localStore.markOperationFailed(
          operation.id,
          operation.retryCount,
        );
        appLogger.w(
          'Échec envoi opération ${operation.id}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    final outstanding = await _localStore.hasOutstandingOperationsForUser(
      userId,
    );
    if (outstanding &&
        await _localStore.hasRetryableOperationsForUser(userId)) {
      _scheduleRetry();
    }
    return succeeded && !outstanding;
  }

  Future<void> _pullRemoteChanges(String userId) async {
    _ensureSession(userId);
    final remoteTasks = await _remote.fetchAll();
    _ensureSession(userId);

    for (final remote in remoteTasks) {
      _ensureSession(userId);
      final local = await _localStore.findTask(remote.id);
      if (local == null) {
        await _localStore.applyRemoteTaskIfQueueEmpty(remote);
        continue;
      }
      if (local.userId != null && local.userId != userId) continue;

      final pending = await _localStore.hasOutstandingOperation(local.id);
      final winner = _conflictResolver.resolve(
        local: local,
        remote: remote,
        hasPendingLocalOperation: pending,
      );

      if (identical(winner, remote)) {
        await _localStore.applyRemoteTaskIfQueueEmpty(remote);
      } else if (!pending && !_sameCloudTask(local, remote)) {
        final canonical = await _remote.upsert(local, userId: userId);
        _ensureSession(userId);
        await _localStore.applyRemoteTaskIfQueueEmpty(canonical);
      }
    }
  }

  void _ensureSession(String expectedUserId) {
    if (_authService.currentUser?.id != expectedUserId) {
      throw const _SessionChanged();
    }
  }

  bool _sameCloudTask(Task local, Task remote) {
    return local.copyWith(syncStatus: SyncStatus.synced) ==
        remote.copyWith(syncStatus: SyncStatus.synced);
  }

  Future<void> _scheduleRetryIfUseful() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;
    final outstanding = await _localStore.hasOutstandingOperationsForUser(
      userId,
    );
    final retryable = await _localStore.hasRetryableOperationsForUser(userId);
    if (!outstanding || retryable) {
      _scheduleRetry();
    } else {
      _cancelRetry();
    }
  }

  void _scheduleRetry() {
    if (_disposed || _retryTimer?.isActive == true) return;
    const delays = [2, 5, 10, 30, 60];
    final retryIndex = _retryAttempt < delays.length
        ? _retryAttempt
        : delays.length - 1;
    final delay = delays[retryIndex];
    _retryAttempt++;
    _retryTimer = Timer(Duration(seconds: delay), () {
      _retryTimer = null;
      syncNow().catchError((Object error, StackTrace stackTrace) {
        appLogger.w(
          'Nouvelle tentative de synchronisation impossible',
          error: error,
          stackTrace: stackTrace,
        );
      });
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelRetry();
    _setSyncing(false);
    unawaited(_syncingController.close());
  }
}

class _SessionChanged implements Exception {
  const _SessionChanged();
}
