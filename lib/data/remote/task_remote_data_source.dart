import 'package:mya/domain/entities/task.dart';

/// Accès distant aux tâches, isolé pour rendre le moteur de sync testable.
abstract interface class TaskRemoteDataSource {
  Future<List<Task>> fetchAll();

  Future<Task> upsert(Task task, {required String userId});
}
