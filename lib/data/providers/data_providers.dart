import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/repositories/drift_task_repository.dart';
import 'package:mya/domain/repositories/task_repository.dart';

/// Base SQLite locale — surchargée au démarrage avec l'instance ouverte.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden during bootstrap.',
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return DriftTaskRepository(ref.watch(appDatabaseProvider));
});
