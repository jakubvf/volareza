import 'package:flutter/material.dart';
import 'database.dart';

class DatabaseProvider extends InheritedWidget {
  const DatabaseProvider({
    super.key,
    required this.database,
    required super.child,
  });

  final AppDatabase database;

  static AppDatabase of(BuildContext context) {
    final DatabaseProvider? result =
        context.dependOnInheritedWidgetOfExactType<DatabaseProvider>();
    assert(result != null, 'No DatabaseProvider found in context');
    return result!.database;
  }

  @override
  bool updateShouldNotify(DatabaseProvider oldWidget) {
    return database != oldWidget.database;
  }
}