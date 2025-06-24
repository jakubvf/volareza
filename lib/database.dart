import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Subjects extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get departmentId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Teachers extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Classrooms extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get areaId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get entryYearId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get date => text()();
  IntColumn get subjectId => integer().nullable()();
  TextColumn get subjectName => text().nullable()();
  TextColumn get topic => text().nullable()();
  TextColumn get subtopic => text().nullable()();
  TextColumn get lessonFormName => text().nullable()();
  IntColumn get lessonOrder => integer().nullable()();
  TextColumn get departmentName => text().nullable()();
  TextColumn get classroomNames => text().nullable()();
  TextColumn get teacherNames => text().nullable()();
  TextColumn get groupNames => text().nullable()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Subjects, Teachers, Classrooms, Groups, Events])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  Future<List<Event>> eventsOfGroupOnDate(String group, DateTime date) {
    return (select(events)
        ..where((e) => e.date.equals(date.toIso8601String().split('T')[0]))
        ..where((e) => e.groupNames.contains(group)))
        .get();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.createTable(subjects);
            await m.createTable(teachers);
            await m.createTable(classrooms);
            await m.createTable(groups);
            await m.createTable(events);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
