import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mya/data/local/tables.dart';

part 'database.g.dart';

/// Base SQLite locale MYA (Drift).
@DriftDatabase(tables: [TaskEntries, SyncOperations, UserSettingsEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Base en mémoire pour les tests unitaires.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(taskEntries, taskEntries.superAlertEnabled);
        await migrator.addColumn(
          taskEntries,
          taskEntries.superAlertAcknowledgedAt,
        );
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mya');
  }
}
