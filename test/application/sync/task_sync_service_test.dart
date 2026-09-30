import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/application/sync/sync_service.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/local/sync_local_store.dart';
import 'package:mya/data/local/sync_metadata_store.dart';
import 'package:mya/data/remote/task_remote_data_source.dart';
import 'package:mya/data/repositories/drift_task_repository.dart';
import 'package:mya/domain/entities/auth_user.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late DriftTaskRepository repository;
  late _FakeTaskRemote remote;
  late SyncMetadataStore metadata;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.forTesting();
    repository = DriftTaskRepository(database);
    remote = _FakeTaskRemote();
    metadata = SyncMetadataStore(await SharedPreferences.getInstance());
  });

  tearDown(() => database.close());

  TaskSyncService createService() {
    return TaskSyncService(
      const _FakeAuthService(),
      SyncLocalStore(database),
      metadata,
      remote,
    );
  }

  test('la fusion initiale envoie les tâches locales sans perte', () async {
    final local = Task.createNew(
      id: 'local-1',
      title: 'Locale',
      now: DateTime(2026, 1, 1),
    );
    await repository.addTask(local);

    await createService().syncNow();

    expect(remote.tasks['local-1']?.title, 'Locale');
    expect(metadata.isInitialMergeCompleted('user-1'), isTrue);
    final stored = await repository.findById('local-1');
    expect(stored?.userId, 'user-1');
    expect(stored?.syncStatus, SyncStatus.synced);
  });

  test('la fusion initiale importe les tâches distantes', () async {
    remote.tasks['remote-1'] = Task.createNew(
      id: 'remote-1',
      title: 'Distante',
      userId: 'user-1',
      now: DateTime(2026, 1, 2),
    ).copyWith(syncStatus: SyncStatus.synced);

    await createService().syncNow();

    final stored = await repository.findById('remote-1');
    expect(stored?.title, 'Distante');
    expect(stored?.syncStatus, SyncStatus.synced);
  });

  test('la file envoie une modification après la première fusion', () async {
    await metadata.markInitialMergeCompleted('user-1');
    final task = Task.createNew(
      id: 'queued-1',
      title: 'À envoyer',
      now: DateTime(2026, 1, 3),
    );
    await repository.addTask(task);

    await createService().syncNow();

    expect(remote.tasks['queued-1']?.title, 'À envoyer');
    final operations = await database.select(database.syncOperations).get();
    expect(operations.single.status, 'sent');
    expect(
      (await repository.findById('queued-1'))?.syncStatus,
      SyncStatus.synced,
    );
  });

  test('le pull applique une version distante plus récente', () async {
    await metadata.markInitialMergeCompleted('user-1');
    final old = Task.createNew(
      id: 'shared-1',
      title: 'Ancienne',
      userId: 'user-1',
      now: DateTime(2026, 1, 1),
    ).copyWith(syncStatus: SyncStatus.synced);
    await SyncLocalStore(database).applyRemoteTask(old);
    remote.tasks['shared-1'] = old
        .touch(title: 'Nouvelle', now: DateTime(2026, 1, 2))
        .copyWith(syncStatus: SyncStatus.synced);

    await createService().syncNow();

    expect((await repository.findById('shared-1'))?.title, 'Nouvelle');
  });

  test(
    'une version cloud plus récente résiste à une ancienne file locale',
    () async {
      await metadata.markInitialMergeCompleted('user-1');
      final local = Task.createNew(
        id: 'conflict-1',
        title: 'Locale ancienne',
        userId: 'user-1',
        now: DateTime(2026, 1, 1),
      );
      await repository.addTask(local);
      remote.tasks['conflict-1'] = local
          .touch(title: 'Cloud récent', now: DateTime(2026, 1, 2))
          .copyWith(syncStatus: SyncStatus.synced);

      await createService().syncNow();

      expect((await repository.findById('conflict-1'))?.title, 'Cloud récent');
    },
  );

  test('une demande pendant la sync provoque un second passage', () async {
    await metadata.markInitialMergeCompleted('user-1');
    final original = Task.createNew(
      id: 'race-1',
      title: 'Version 1',
      userId: 'user-1',
      now: DateTime(2026, 1, 1),
    );
    await repository.addTask(original);
    final service = createService();
    var changed = false;
    remote.onUpsert = () async {
      if (changed) return;
      changed = true;
      await repository.updateTask(
        original.touch(title: 'Version 2', now: DateTime(2026, 1, 2)),
      );
      unawaited(service.syncNow());
    };

    await service.syncNow();

    expect(remote.tasks['race-1']?.title, 'Version 2');
    final operations = await database.select(database.syncOperations).get();
    expect(
      operations.where((operation) => operation.status != 'sent'),
      isEmpty,
    );
  });

  test('une opération interrompue est reprise au lancement suivant', () async {
    await metadata.markInitialMergeCompleted('user-1');
    final task = Task.createNew(
      id: 'interrupted-1',
      title: 'À reprendre',
      userId: 'user-1',
      now: DateTime(2026, 1, 1),
    );
    await repository.addTask(task);
    final operation =
        (await database.select(database.syncOperations).get()).single;
    await SyncLocalStore(database).markOperationInProgress(operation.id);

    await createService().syncNow();

    expect(remote.tasks['interrupted-1']?.title, 'À reprendre');
    final storedOperation =
        (await database.select(database.syncOperations).get()).single;
    expect(storedOperation.status, 'sent');
  });

  test(
    "la fusion initiale n'est pas validée après des échecs répétés",
    () async {
      await repository.addTask(
        Task.createNew(
          id: 'failed-1',
          title: 'En échec',
          now: DateTime(2026, 1, 1),
        ),
      );
      remote.upsertError = StateError('Supabase indisponible');
      final service = createService();

      for (var attempt = 0; attempt < 5; attempt++) {
        await expectLater(service.syncNow(), throwsStateError);
      }

      expect(metadata.isInitialMergeCompleted('user-1'), isFalse);
      final operation =
          (await database.select(database.syncOperations).get()).single;
      expect(operation.retryCount, 5);
      expect(operation.status, 'failed');
      service.dispose();
    },
  );

  test('un échec serveur est retenté sans changement de réseau', () async {
    await metadata.markInitialMergeCompleted('user-1');
    await repository.addTask(
      Task.createNew(id: 'retry-1', title: 'À retenter', userId: 'user-1'),
    );
    remote.failuresRemaining = 1;
    final service = createService();

    await expectLater(service.syncNow(), throwsStateError);
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    expect(remote.tasks['retry-1']?.title, 'À retenter');
    service.dispose();
  });
}

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  static const user = AuthUser(id: 'user-1', email: 'test@example.com');

  @override
  bool get isConfigured => true;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(user);

  @override
  Future<void> signInWithProvider(MyaAuthProvider provider) async {}

  @override
  Future<void> signOut() async {}
}

class _FakeTaskRemote implements TaskRemoteDataSource {
  final tasks = <String, Task>{};
  Future<void> Function()? onUpsert;
  Object? upsertError;
  int failuresRemaining = 0;

  @override
  Future<List<Task>> fetchAll() async => tasks.values.toList();

  @override
  Future<Task> upsert(Task task, {required String userId}) async {
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('Échec temporaire');
    }
    final error = upsertError;
    if (error != null) throw error;
    await onUpsert?.call();
    final existing = tasks[task.id];
    if (existing != null && existing.updatedAt.isAfter(task.updatedAt)) {
      return existing;
    }
    final synchronized = task.copyWith(
      userId: userId,
      syncStatus: SyncStatus.synced,
    );
    tasks[task.id] = synchronized;
    return synchronized;
  }
}
