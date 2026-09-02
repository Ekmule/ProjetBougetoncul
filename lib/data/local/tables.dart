import 'package:drift/drift.dart';

/// Table des tâches — miroir local du modèle cloud.
@DataClassName('TaskRow')
class TaskEntries extends Table {
  @override
  String get tableName => 'tasks';

  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get status => text()();
  TextColumn get category => text()();
  TextColumn get plannedDate => text().nullable()();
  IntColumn get reminderAt => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// File de synchronisation — locale uniquement.
class SyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get lastAttemptAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Préférences utilisateur synchronisables.
@DataClassName('UserSettingsRow')
class UserSettingsEntries extends Table {
  @override
  String get tableName => 'user_settings';

  TextColumn get userId => text().nullable()();
  TextColumn get categoryLabelMustDo =>
      text().withDefault(const Constant('BOUGE TON GROS CUL'))();
  TextColumn get categoryLabelToday =>
      text().withDefault(const Constant('AUJOURD\'HUI'))();
  TextColumn get categoryLabelNext =>
      text().withDefault(const Constant('ENSUITE'))();
  TextColumn get categoryLabelSomeday =>
      text().withDefault(const Constant('À FAIRE SI J\'AI LE TEMPS'))();
  BoolColumn get humorEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get historyRetentionDays =>
      integer().withDefault(const Constant(7))();
  TextColumn get notificationStyle =>
      text().withDefault(const Constant('normal'))();
  TextColumn get themePreference =>
      text().withDefault(const Constant('system'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}
