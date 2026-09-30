import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/sync/sync_conflict_resolver.dart';
import 'package:mya/domain/entities/task.dart';

void main() {
  const resolver = SyncConflictResolver();

  Task task(String title, DateTime updatedAt) {
    return Task.createNew(id: 'task-1', title: title, now: updatedAt);
  }

  test('une opération locale en attente protège la version locale', () {
    final local = task('local', DateTime(2026, 1, 1));
    final remote = task('remote', DateTime(2026, 1, 2));

    final result = resolver.resolve(
      local: local,
      remote: remote,
      hasPendingLocalOperation: true,
    );

    expect(result, same(local));
  });

  test('la version distante la plus récente gagne sans opération locale', () {
    final local = task('local', DateTime(2026, 1, 1));
    final remote = task('remote', DateTime(2026, 1, 2));

    final result = resolver.resolve(
      local: local,
      remote: remote,
      hasPendingLocalOperation: false,
    );

    expect(result, same(remote));
  });

  test('une suppression distante plus récente gagne', () {
    final local = task('local', DateTime(2026, 1, 1));
    final remote = task(
      'remote',
      DateTime(2026, 1, 1),
    ).softDelete(now: DateTime(2026, 1, 3));

    final result = resolver.resolve(
      local: local,
      remote: remote,
      hasPendingLocalOperation: false,
    );

    expect(result, same(remote));
  });
}
