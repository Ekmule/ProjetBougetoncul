import 'package:mya/data/models/task_cloud_mapper.dart';
import 'package:mya/data/remote/task_remote_data_source.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTaskRemoteDataSource implements TaskRemoteDataSource {
  SupabaseTaskRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Task>> fetchAll() async {
    const pageSize = 500;
    final tasksById = <String, Task>{};
    String? cursorUpdatedAt;
    String? cursorId;

    while (true) {
      var query = _client.from('tasks').select();
      if (cursorUpdatedAt != null && cursorId != null) {
        query = query.or(
          'updated_at.gt.$cursorUpdatedAt,'
          'and(updated_at.eq.$cursorUpdatedAt,id.gt.$cursorId)',
        );
      }
      final response = await query
          .order('updated_at')
          .order('id')
          .limit(pageSize);
      for (final row in response) {
        final task = TaskCloudMapper.fromJson(row);
        tasksById[task.id] = task;
      }
      if (response.length < pageSize) break;
      final last = response.last;
      cursorUpdatedAt = last['updated_at'] as String;
      cursorId = last['id'] as String;
    }

    return tasksById.values.toList(growable: false);
  }

  @override
  Future<Task> upsert(Task task, {required String userId}) async {
    final response = await _client.rpc(
      'sync_task',
      params: {'p_task': TaskCloudMapper.toJson(task, userId: userId)},
    );
    final row = switch (response) {
      Map<String, dynamic> value => value,
      List<dynamic> value when value.isNotEmpty => Map<String, dynamic>.from(
        value.first as Map,
      ),
      _ => throw const FormatException('Réponse sync_task invalide.'),
    };
    return TaskCloudMapper.fromJson(row);
  }
}
