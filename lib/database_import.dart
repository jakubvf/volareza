import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'database.dart';

class DatabaseImporter {
  static Future<void> importFromAssets(AppDatabase database) async {
    // Load JSON from assets as bytes to avoid string decompression overhead
    final ByteData data = await rootBundle.load('assets/rozvrh.json');
    final Uint8List bytes = data.buffer.asUint8List();
    final jsonString = utf8.decode(bytes);
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Clear existing data
    await _clearAllTables(database);

    // Import data in order (due to potential foreign key constraints)
    await _insertSubjects(database, jsonData['subjects'] as List<dynamic>);
    await _insertTeachers(database, jsonData['teachers'] as List<dynamic>);
    await _insertClassrooms(database, jsonData['classrooms'] as List<dynamic>);
    await _insertGroups(database, jsonData['groups'] as List<dynamic>);
    await _insertEvents(database, jsonData['events'] as List<dynamic>);
  }

  static Future<void> _clearAllTables(AppDatabase database) async {
    await database.delete(database.events).go();
    await database.delete(database.groups).go();
    await database.delete(database.classrooms).go();
    await database.delete(database.teachers).go();
    await database.delete(database.subjects).go();
  }

  static Future<void> _insertSubjects(
    AppDatabase database,
    List<dynamic> subjects,
  ) async {
    for (final subject in subjects) {
      final subjectData = subject as Map<String, dynamic>;
      await database
          .into(database.subjects)
          .insert(
            SubjectsCompanion.insert(
              id: Value(subjectData['id'] as int),
              name: subjectData['name'] as String,
              departmentId: Value(subjectData['departmentId'] as int?),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  static Future<void> _insertTeachers(
    AppDatabase database,
    List<dynamic> teachers,
  ) async {
    for (final teacher in teachers) {
      final teacherData = teacher as Map<String, dynamic>;
      await database
          .into(database.teachers)
          .insert(
            TeachersCompanion.insert(
              id: Value(teacherData['id'] as int),
              name: teacherData['name'] as String,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  static Future<void> _insertClassrooms(
    AppDatabase database,
    List<dynamic> classrooms,
  ) async {
    for (final classroom in classrooms) {
      final classroomData = classroom as Map<String, dynamic>;
      await database
          .into(database.classrooms)
          .insert(
            ClassroomsCompanion.insert(
              id: Value(classroomData['id'] as int),
              name: classroomData['name'] as String,
              areaId: Value(classroomData['areaId'] as int?),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  static Future<void> _insertGroups(AppDatabase database, List<dynamic> groups) async {
    for (final group in groups) {
      final groupData = group as Map<String, dynamic>;
      await database
          .into(database.groups)
          .insert(
            GroupsCompanion.insert(
              id: groupData['id'] as String,
              name: groupData['name'] as String,
              entryYearId: Value(groupData['entryYearId'] as int?),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  static Future<void> _insertEvents(AppDatabase database, List<dynamic> events) async {
    for (final event in events) {
      final eventData = event as Map<String, dynamic>;

      // Format time from {hours: 8, minutes: 0} to "08:00"
      String formatTime(Map<String, dynamic> time) {
        final hours = time['hours'] as int;
        final minutes = time['minutes'] as int;
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      }

      final startTime = formatTime(
        eventData['startTime'] as Map<String, dynamic>,
      );
      final endTime = formatTime(eventData['endTime'] as Map<String, dynamic>);

      // Convert arrays to JSON strings
      final classroomNames = jsonEncode(
        eventData['classroomsNames'] as List<dynamic>,
      );
      final teacherNames = jsonEncode(
        eventData['teachersNames'] as List<dynamic>,
      );
      final groupNames = jsonEncode(eventData['groupsNames'] as List<dynamic>);

      await database
          .into(database.events)
          .insert(
            EventsCompanion.insert(
              id: eventData['id'] as String,
              startTime: startTime,
              endTime: endTime,
              date: eventData['dateCode'] as String,
              subjectId: Value(eventData['subjectId'] as int?),
              subjectName: Value(eventData['subjectName'] as String?),
              topic: Value(eventData['topic'] as String?),
              subtopic: Value(eventData['subtopic'] as String?),
              lessonFormName: Value(eventData['lessonFormName'] as String?),
              lessonOrder: Value(eventData['lessonOrder'] as int?),
              departmentName: Value(eventData['departmentName'] as String?),
              classroomNames: Value(classroomNames),
              teacherNames: Value(teacherNames),
              groupNames: Value(groupNames),
              isLocked: Value(eventData['isLocked'] as bool? ?? false),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }
}