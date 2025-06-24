// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _departmentIdMeta =
      const VerificationMeta('departmentId');
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
      'department_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, departmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('department_id')) {
      context.handle(
          _departmentIdMeta,
          departmentId.isAcceptableOrUnknown(
              data['department_id']!, _departmentIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      departmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}department_id']),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final int? departmentId;
  const Subject({required this.id, required this.name, this.departmentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || departmentId != null) {
      map['department_id'] = Variable<int>(departmentId);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      departmentId: departmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(departmentId),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      departmentId: serializer.fromJson<int?>(json['departmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'departmentId': serializer.toJson<int?>(departmentId),
    };
  }

  Subject copyWith(
          {int? id,
          String? name,
          Value<int?> departmentId = const Value.absent()}) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        departmentId:
            departmentId.present ? departmentId.value : this.departmentId,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('departmentId: $departmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, departmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.departmentId == this.departmentId);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> departmentId;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.departmentId = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.departmentId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? departmentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (departmentId != null) 'department_id': departmentId,
    });
  }

  SubjectsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<int?>? departmentId}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('departmentId: $departmentId')
          ..write(')'))
        .toString();
  }
}

class $TeachersTable extends Teachers with TableInfo<$TeachersTable, Teacher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeachersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teachers';
  @override
  VerificationContext validateIntegrity(Insertable<Teacher> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Teacher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Teacher(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TeachersTable createAlias(String alias) {
    return $TeachersTable(attachedDatabase, alias);
  }
}

class Teacher extends DataClass implements Insertable<Teacher> {
  final int id;
  final String name;
  const Teacher({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TeachersCompanion toCompanion(bool nullToAbsent) {
    return TeachersCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Teacher.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Teacher(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Teacher copyWith({int? id, String? name}) => Teacher(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Teacher copyWithCompanion(TeachersCompanion data) {
    return Teacher(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Teacher(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Teacher && other.id == this.id && other.name == this.name);
}

class TeachersCompanion extends UpdateCompanion<Teacher> {
  final Value<int> id;
  final Value<String> name;
  const TeachersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TeachersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Teacher> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TeachersCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TeachersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeachersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ClassroomsTable extends Classrooms
    with TableInfo<$ClassroomsTable, Classroom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassroomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<int> areaId = GeneratedColumn<int>(
      'area_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, areaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classrooms';
  @override
  VerificationContext validateIntegrity(Insertable<Classroom> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(_areaIdMeta,
          areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Classroom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Classroom(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      areaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}area_id']),
    );
  }

  @override
  $ClassroomsTable createAlias(String alias) {
    return $ClassroomsTable(attachedDatabase, alias);
  }
}

class Classroom extends DataClass implements Insertable<Classroom> {
  final int id;
  final String name;
  final int? areaId;
  const Classroom({required this.id, required this.name, this.areaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<int>(areaId);
    }
    return map;
  }

  ClassroomsCompanion toCompanion(bool nullToAbsent) {
    return ClassroomsCompanion(
      id: Value(id),
      name: Value(name),
      areaId:
          areaId == null && nullToAbsent ? const Value.absent() : Value(areaId),
    );
  }

  factory Classroom.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Classroom(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      areaId: serializer.fromJson<int?>(json['areaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'areaId': serializer.toJson<int?>(areaId),
    };
  }

  Classroom copyWith(
          {int? id, String? name, Value<int?> areaId = const Value.absent()}) =>
      Classroom(
        id: id ?? this.id,
        name: name ?? this.name,
        areaId: areaId.present ? areaId.value : this.areaId,
      );
  Classroom copyWithCompanion(ClassroomsCompanion data) {
    return Classroom(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Classroom(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('areaId: $areaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, areaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Classroom &&
          other.id == this.id &&
          other.name == this.name &&
          other.areaId == this.areaId);
}

class ClassroomsCompanion extends UpdateCompanion<Classroom> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> areaId;
  const ClassroomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.areaId = const Value.absent(),
  });
  ClassroomsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.areaId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Classroom> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? areaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (areaId != null) 'area_id': areaId,
    });
  }

  ClassroomsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<int?>? areaId}) {
    return ClassroomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      areaId: areaId ?? this.areaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<int>(areaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassroomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('areaId: $areaId')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryYearIdMeta =
      const VerificationMeta('entryYearId');
  @override
  late final GeneratedColumn<int> entryYearId = GeneratedColumn<int>(
      'entry_year_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, entryYearId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('entry_year_id')) {
      context.handle(
          _entryYearIdMeta,
          entryYearId.isAcceptableOrUnknown(
              data['entry_year_id']!, _entryYearIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      entryYearId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entry_year_id']),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String id;
  final String name;
  final int? entryYearId;
  const Group({required this.id, required this.name, this.entryYearId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || entryYearId != null) {
      map['entry_year_id'] = Variable<int>(entryYearId);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      entryYearId: entryYearId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryYearId),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      entryYearId: serializer.fromJson<int?>(json['entryYearId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'entryYearId': serializer.toJson<int?>(entryYearId),
    };
  }

  Group copyWith(
          {String? id,
          String? name,
          Value<int?> entryYearId = const Value.absent()}) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        entryYearId: entryYearId.present ? entryYearId.value : this.entryYearId,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      entryYearId:
          data.entryYearId.present ? data.entryYearId.value : this.entryYearId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('entryYearId: $entryYearId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, entryYearId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.entryYearId == this.entryYearId);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> entryYearId;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.entryYearId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    this.entryYearId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Group> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? entryYearId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (entryYearId != null) 'entry_year_id': entryYearId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int?>? entryYearId,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      entryYearId: entryYearId ?? this.entryYearId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (entryYearId.present) {
      map['entry_year_id'] = Variable<int>(entryYearId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('entryYearId: $entryYearId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _subjectNameMeta =
      const VerificationMeta('subjectName');
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
      'subject_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subtopicMeta =
      const VerificationMeta('subtopic');
  @override
  late final GeneratedColumn<String> subtopic = GeneratedColumn<String>(
      'subtopic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lessonFormNameMeta =
      const VerificationMeta('lessonFormName');
  @override
  late final GeneratedColumn<String> lessonFormName = GeneratedColumn<String>(
      'lesson_form_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lessonOrderMeta =
      const VerificationMeta('lessonOrder');
  @override
  late final GeneratedColumn<int> lessonOrder = GeneratedColumn<int>(
      'lesson_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _departmentNameMeta =
      const VerificationMeta('departmentName');
  @override
  late final GeneratedColumn<String> departmentName = GeneratedColumn<String>(
      'department_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _classroomNamesMeta =
      const VerificationMeta('classroomNames');
  @override
  late final GeneratedColumn<String> classroomNames = GeneratedColumn<String>(
      'classroom_names', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teacherNamesMeta =
      const VerificationMeta('teacherNames');
  @override
  late final GeneratedColumn<String> teacherNames = GeneratedColumn<String>(
      'teacher_names', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupNamesMeta =
      const VerificationMeta('groupNames');
  @override
  late final GeneratedColumn<String> groupNames = GeneratedColumn<String>(
      'group_names', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startTime,
        endTime,
        date,
        subjectId,
        subjectName,
        topic,
        subtopic,
        lessonFormName,
        lessonOrder,
        departmentName,
        classroomNames,
        teacherNames,
        groupNames,
        isLocked
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    }
    if (data.containsKey('subject_name')) {
      context.handle(
          _subjectNameMeta,
          subjectName.isAcceptableOrUnknown(
              data['subject_name']!, _subjectNameMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('subtopic')) {
      context.handle(_subtopicMeta,
          subtopic.isAcceptableOrUnknown(data['subtopic']!, _subtopicMeta));
    }
    if (data.containsKey('lesson_form_name')) {
      context.handle(
          _lessonFormNameMeta,
          lessonFormName.isAcceptableOrUnknown(
              data['lesson_form_name']!, _lessonFormNameMeta));
    }
    if (data.containsKey('lesson_order')) {
      context.handle(
          _lessonOrderMeta,
          lessonOrder.isAcceptableOrUnknown(
              data['lesson_order']!, _lessonOrderMeta));
    }
    if (data.containsKey('department_name')) {
      context.handle(
          _departmentNameMeta,
          departmentName.isAcceptableOrUnknown(
              data['department_name']!, _departmentNameMeta));
    }
    if (data.containsKey('classroom_names')) {
      context.handle(
          _classroomNamesMeta,
          classroomNames.isAcceptableOrUnknown(
              data['classroom_names']!, _classroomNamesMeta));
    }
    if (data.containsKey('teacher_names')) {
      context.handle(
          _teacherNamesMeta,
          teacherNames.isAcceptableOrUnknown(
              data['teacher_names']!, _teacherNamesMeta));
    }
    if (data.containsKey('group_names')) {
      context.handle(
          _groupNamesMeta,
          groupNames.isAcceptableOrUnknown(
              data['group_names']!, _groupNamesMeta));
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id']),
      subjectName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_name']),
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      subtopic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtopic']),
      lessonFormName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}lesson_form_name']),
      lessonOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lesson_order']),
      departmentName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department_name']),
      classroomNames: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}classroom_names']),
      teacherNames: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_names']),
      groupNames: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_names']),
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String startTime;
  final String endTime;
  final String date;
  final int? subjectId;
  final String? subjectName;
  final String? topic;
  final String? subtopic;
  final String? lessonFormName;
  final int? lessonOrder;
  final String? departmentName;
  final String? classroomNames;
  final String? teacherNames;
  final String? groupNames;
  final bool isLocked;
  const Event(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.date,
      this.subjectId,
      this.subjectName,
      this.topic,
      this.subtopic,
      this.lessonFormName,
      this.lessonOrder,
      this.departmentName,
      this.classroomNames,
      this.teacherNames,
      this.groupNames,
      required this.isLocked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
    }
    if (!nullToAbsent || subjectName != null) {
      map['subject_name'] = Variable<String>(subjectName);
    }
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || subtopic != null) {
      map['subtopic'] = Variable<String>(subtopic);
    }
    if (!nullToAbsent || lessonFormName != null) {
      map['lesson_form_name'] = Variable<String>(lessonFormName);
    }
    if (!nullToAbsent || lessonOrder != null) {
      map['lesson_order'] = Variable<int>(lessonOrder);
    }
    if (!nullToAbsent || departmentName != null) {
      map['department_name'] = Variable<String>(departmentName);
    }
    if (!nullToAbsent || classroomNames != null) {
      map['classroom_names'] = Variable<String>(classroomNames);
    }
    if (!nullToAbsent || teacherNames != null) {
      map['teacher_names'] = Variable<String>(teacherNames);
    }
    if (!nullToAbsent || groupNames != null) {
      map['group_names'] = Variable<String>(groupNames);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: Value(endTime),
      date: Value(date),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      subjectName: subjectName == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectName),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      subtopic: subtopic == null && nullToAbsent
          ? const Value.absent()
          : Value(subtopic),
      lessonFormName: lessonFormName == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonFormName),
      lessonOrder: lessonOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonOrder),
      departmentName: departmentName == null && nullToAbsent
          ? const Value.absent()
          : Value(departmentName),
      classroomNames: classroomNames == null && nullToAbsent
          ? const Value.absent()
          : Value(classroomNames),
      teacherNames: teacherNames == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherNames),
      groupNames: groupNames == null && nullToAbsent
          ? const Value.absent()
          : Value(groupNames),
      isLocked: Value(isLocked),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      date: serializer.fromJson<String>(json['date']),
      subjectId: serializer.fromJson<int?>(json['subjectId']),
      subjectName: serializer.fromJson<String?>(json['subjectName']),
      topic: serializer.fromJson<String?>(json['topic']),
      subtopic: serializer.fromJson<String?>(json['subtopic']),
      lessonFormName: serializer.fromJson<String?>(json['lessonFormName']),
      lessonOrder: serializer.fromJson<int?>(json['lessonOrder']),
      departmentName: serializer.fromJson<String?>(json['departmentName']),
      classroomNames: serializer.fromJson<String?>(json['classroomNames']),
      teacherNames: serializer.fromJson<String?>(json['teacherNames']),
      groupNames: serializer.fromJson<String?>(json['groupNames']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'date': serializer.toJson<String>(date),
      'subjectId': serializer.toJson<int?>(subjectId),
      'subjectName': serializer.toJson<String?>(subjectName),
      'topic': serializer.toJson<String?>(topic),
      'subtopic': serializer.toJson<String?>(subtopic),
      'lessonFormName': serializer.toJson<String?>(lessonFormName),
      'lessonOrder': serializer.toJson<int?>(lessonOrder),
      'departmentName': serializer.toJson<String?>(departmentName),
      'classroomNames': serializer.toJson<String?>(classroomNames),
      'teacherNames': serializer.toJson<String?>(teacherNames),
      'groupNames': serializer.toJson<String?>(groupNames),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  Event copyWith(
          {String? id,
          String? startTime,
          String? endTime,
          String? date,
          Value<int?> subjectId = const Value.absent(),
          Value<String?> subjectName = const Value.absent(),
          Value<String?> topic = const Value.absent(),
          Value<String?> subtopic = const Value.absent(),
          Value<String?> lessonFormName = const Value.absent(),
          Value<int?> lessonOrder = const Value.absent(),
          Value<String?> departmentName = const Value.absent(),
          Value<String?> classroomNames = const Value.absent(),
          Value<String?> teacherNames = const Value.absent(),
          Value<String?> groupNames = const Value.absent(),
          bool? isLocked}) =>
      Event(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        date: date ?? this.date,
        subjectId: subjectId.present ? subjectId.value : this.subjectId,
        subjectName: subjectName.present ? subjectName.value : this.subjectName,
        topic: topic.present ? topic.value : this.topic,
        subtopic: subtopic.present ? subtopic.value : this.subtopic,
        lessonFormName:
            lessonFormName.present ? lessonFormName.value : this.lessonFormName,
        lessonOrder: lessonOrder.present ? lessonOrder.value : this.lessonOrder,
        departmentName:
            departmentName.present ? departmentName.value : this.departmentName,
        classroomNames:
            classroomNames.present ? classroomNames.value : this.classroomNames,
        teacherNames:
            teacherNames.present ? teacherNames.value : this.teacherNames,
        groupNames: groupNames.present ? groupNames.value : this.groupNames,
        isLocked: isLocked ?? this.isLocked,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      date: data.date.present ? data.date.value : this.date,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      subjectName:
          data.subjectName.present ? data.subjectName.value : this.subjectName,
      topic: data.topic.present ? data.topic.value : this.topic,
      subtopic: data.subtopic.present ? data.subtopic.value : this.subtopic,
      lessonFormName: data.lessonFormName.present
          ? data.lessonFormName.value
          : this.lessonFormName,
      lessonOrder:
          data.lessonOrder.present ? data.lessonOrder.value : this.lessonOrder,
      departmentName: data.departmentName.present
          ? data.departmentName.value
          : this.departmentName,
      classroomNames: data.classroomNames.present
          ? data.classroomNames.value
          : this.classroomNames,
      teacherNames: data.teacherNames.present
          ? data.teacherNames.value
          : this.teacherNames,
      groupNames:
          data.groupNames.present ? data.groupNames.value : this.groupNames,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('date: $date, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectName: $subjectName, ')
          ..write('topic: $topic, ')
          ..write('subtopic: $subtopic, ')
          ..write('lessonFormName: $lessonFormName, ')
          ..write('lessonOrder: $lessonOrder, ')
          ..write('departmentName: $departmentName, ')
          ..write('classroomNames: $classroomNames, ')
          ..write('teacherNames: $teacherNames, ')
          ..write('groupNames: $groupNames, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      startTime,
      endTime,
      date,
      subjectId,
      subjectName,
      topic,
      subtopic,
      lessonFormName,
      lessonOrder,
      departmentName,
      classroomNames,
      teacherNames,
      groupNames,
      isLocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.date == this.date &&
          other.subjectId == this.subjectId &&
          other.subjectName == this.subjectName &&
          other.topic == this.topic &&
          other.subtopic == this.subtopic &&
          other.lessonFormName == this.lessonFormName &&
          other.lessonOrder == this.lessonOrder &&
          other.departmentName == this.departmentName &&
          other.classroomNames == this.classroomNames &&
          other.teacherNames == this.teacherNames &&
          other.groupNames == this.groupNames &&
          other.isLocked == this.isLocked);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> date;
  final Value<int?> subjectId;
  final Value<String?> subjectName;
  final Value<String?> topic;
  final Value<String?> subtopic;
  final Value<String?> lessonFormName;
  final Value<int?> lessonOrder;
  final Value<String?> departmentName;
  final Value<String?> classroomNames;
  final Value<String?> teacherNames;
  final Value<String?> groupNames;
  final Value<bool> isLocked;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.date = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.topic = const Value.absent(),
    this.subtopic = const Value.absent(),
    this.lessonFormName = const Value.absent(),
    this.lessonOrder = const Value.absent(),
    this.departmentName = const Value.absent(),
    this.classroomNames = const Value.absent(),
    this.teacherNames = const Value.absent(),
    this.groupNames = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String startTime,
    required String endTime,
    required String date,
    this.subjectId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.topic = const Value.absent(),
    this.subtopic = const Value.absent(),
    this.lessonFormName = const Value.absent(),
    this.lessonOrder = const Value.absent(),
    this.departmentName = const Value.absent(),
    this.classroomNames = const Value.absent(),
    this.teacherNames = const Value.absent(),
    this.groupNames = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startTime = Value(startTime),
        endTime = Value(endTime),
        date = Value(date);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? date,
    Expression<int>? subjectId,
    Expression<String>? subjectName,
    Expression<String>? topic,
    Expression<String>? subtopic,
    Expression<String>? lessonFormName,
    Expression<int>? lessonOrder,
    Expression<String>? departmentName,
    Expression<String>? classroomNames,
    Expression<String>? teacherNames,
    Expression<String>? groupNames,
    Expression<bool>? isLocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (date != null) 'date': date,
      if (subjectId != null) 'subject_id': subjectId,
      if (subjectName != null) 'subject_name': subjectName,
      if (topic != null) 'topic': topic,
      if (subtopic != null) 'subtopic': subtopic,
      if (lessonFormName != null) 'lesson_form_name': lessonFormName,
      if (lessonOrder != null) 'lesson_order': lessonOrder,
      if (departmentName != null) 'department_name': departmentName,
      if (classroomNames != null) 'classroom_names': classroomNames,
      if (teacherNames != null) 'teacher_names': teacherNames,
      if (groupNames != null) 'group_names': groupNames,
      if (isLocked != null) 'is_locked': isLocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String>? date,
      Value<int?>? subjectId,
      Value<String?>? subjectName,
      Value<String?>? topic,
      Value<String?>? subtopic,
      Value<String?>? lessonFormName,
      Value<int?>? lessonOrder,
      Value<String?>? departmentName,
      Value<String?>? classroomNames,
      Value<String?>? teacherNames,
      Value<String?>? groupNames,
      Value<bool>? isLocked,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      topic: topic ?? this.topic,
      subtopic: subtopic ?? this.subtopic,
      lessonFormName: lessonFormName ?? this.lessonFormName,
      lessonOrder: lessonOrder ?? this.lessonOrder,
      departmentName: departmentName ?? this.departmentName,
      classroomNames: classroomNames ?? this.classroomNames,
      teacherNames: teacherNames ?? this.teacherNames,
      groupNames: groupNames ?? this.groupNames,
      isLocked: isLocked ?? this.isLocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (subtopic.present) {
      map['subtopic'] = Variable<String>(subtopic.value);
    }
    if (lessonFormName.present) {
      map['lesson_form_name'] = Variable<String>(lessonFormName.value);
    }
    if (lessonOrder.present) {
      map['lesson_order'] = Variable<int>(lessonOrder.value);
    }
    if (departmentName.present) {
      map['department_name'] = Variable<String>(departmentName.value);
    }
    if (classroomNames.present) {
      map['classroom_names'] = Variable<String>(classroomNames.value);
    }
    if (teacherNames.present) {
      map['teacher_names'] = Variable<String>(teacherNames.value);
    }
    if (groupNames.present) {
      map['group_names'] = Variable<String>(groupNames.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('date: $date, ')
          ..write('subjectId: $subjectId, ')
          ..write('subjectName: $subjectName, ')
          ..write('topic: $topic, ')
          ..write('subtopic: $subtopic, ')
          ..write('lessonFormName: $lessonFormName, ')
          ..write('lessonOrder: $lessonOrder, ')
          ..write('departmentName: $departmentName, ')
          ..write('classroomNames: $classroomNames, ')
          ..write('teacherNames: $teacherNames, ')
          ..write('groupNames: $groupNames, ')
          ..write('isLocked: $isLocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $TeachersTable teachers = $TeachersTable(this);
  late final $ClassroomsTable classrooms = $ClassroomsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $EventsTable events = $EventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [subjects, teachers, classrooms, groups, events];
}

typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> departmentId,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> departmentId,
});

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get departmentId => $composableBuilder(
      column: $table.departmentId, builder: (column) => ColumnFilters(column));
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get departmentId => $composableBuilder(
      column: $table.departmentId,
      builder: (column) => ColumnOrderings(column));
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get departmentId => $composableBuilder(
      column: $table.departmentId, builder: (column) => column);
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
    Subject,
    PrefetchHooks Function()> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> departmentId = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            name: name,
            departmentId: departmentId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int?> departmentId = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            name: name,
            departmentId: departmentId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
    Subject,
    PrefetchHooks Function()>;
typedef $$TeachersTableCreateCompanionBuilder = TeachersCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$TeachersTableUpdateCompanionBuilder = TeachersCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$TeachersTableFilterComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$TeachersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TeachersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TeachersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TeachersTable,
    Teacher,
    $$TeachersTableFilterComposer,
    $$TeachersTableOrderingComposer,
    $$TeachersTableAnnotationComposer,
    $$TeachersTableCreateCompanionBuilder,
    $$TeachersTableUpdateCompanionBuilder,
    (Teacher, BaseReferences<_$AppDatabase, $TeachersTable, Teacher>),
    Teacher,
    PrefetchHooks Function()> {
  $$TeachersTableTableManager(_$AppDatabase db, $TeachersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeachersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeachersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeachersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              TeachersCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              TeachersCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TeachersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TeachersTable,
    Teacher,
    $$TeachersTableFilterComposer,
    $$TeachersTableOrderingComposer,
    $$TeachersTableAnnotationComposer,
    $$TeachersTableCreateCompanionBuilder,
    $$TeachersTableUpdateCompanionBuilder,
    (Teacher, BaseReferences<_$AppDatabase, $TeachersTable, Teacher>),
    Teacher,
    PrefetchHooks Function()>;
typedef $$ClassroomsTableCreateCompanionBuilder = ClassroomsCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> areaId,
});
typedef $$ClassroomsTableUpdateCompanionBuilder = ClassroomsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> areaId,
});

class $$ClassroomsTableFilterComposer
    extends Composer<_$AppDatabase, $ClassroomsTable> {
  $$ClassroomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnFilters(column));
}

class $$ClassroomsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassroomsTable> {
  $$ClassroomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnOrderings(column));
}

class $$ClassroomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassroomsTable> {
  $$ClassroomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);
}

class $$ClassroomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClassroomsTable,
    Classroom,
    $$ClassroomsTableFilterComposer,
    $$ClassroomsTableOrderingComposer,
    $$ClassroomsTableAnnotationComposer,
    $$ClassroomsTableCreateCompanionBuilder,
    $$ClassroomsTableUpdateCompanionBuilder,
    (Classroom, BaseReferences<_$AppDatabase, $ClassroomsTable, Classroom>),
    Classroom,
    PrefetchHooks Function()> {
  $$ClassroomsTableTableManager(_$AppDatabase db, $ClassroomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassroomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassroomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassroomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> areaId = const Value.absent(),
          }) =>
              ClassroomsCompanion(
            id: id,
            name: name,
            areaId: areaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int?> areaId = const Value.absent(),
          }) =>
              ClassroomsCompanion.insert(
            id: id,
            name: name,
            areaId: areaId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClassroomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClassroomsTable,
    Classroom,
    $$ClassroomsTableFilterComposer,
    $$ClassroomsTableOrderingComposer,
    $$ClassroomsTableAnnotationComposer,
    $$ClassroomsTableCreateCompanionBuilder,
    $$ClassroomsTableUpdateCompanionBuilder,
    (Classroom, BaseReferences<_$AppDatabase, $ClassroomsTable, Classroom>),
    Classroom,
    PrefetchHooks Function()>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required String name,
  Value<int?> entryYearId,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> entryYearId,
  Value<int> rowid,
});

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entryYearId => $composableBuilder(
      column: $table.entryYearId, builder: (column) => ColumnFilters(column));
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entryYearId => $composableBuilder(
      column: $table.entryYearId, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get entryYearId => $composableBuilder(
      column: $table.entryYearId, builder: (column) => column);
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
    Group,
    PrefetchHooks Function()> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> entryYearId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            entryYearId: entryYearId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int?> entryYearId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            entryYearId: entryYearId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
    Group,
    PrefetchHooks Function()>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String startTime,
  required String endTime,
  required String date,
  Value<int?> subjectId,
  Value<String?> subjectName,
  Value<String?> topic,
  Value<String?> subtopic,
  Value<String?> lessonFormName,
  Value<int?> lessonOrder,
  Value<String?> departmentName,
  Value<String?> classroomNames,
  Value<String?> teacherNames,
  Value<String?> groupNames,
  Value<bool> isLocked,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> date,
  Value<int?> subjectId,
  Value<String?> subjectName,
  Value<String?> topic,
  Value<String?> subtopic,
  Value<String?> lessonFormName,
  Value<int?> lessonOrder,
  Value<String?> departmentName,
  Value<String?> classroomNames,
  Value<String?> teacherNames,
  Value<String?> groupNames,
  Value<bool> isLocked,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectName => $composableBuilder(
      column: $table.subjectName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtopic => $composableBuilder(
      column: $table.subtopic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lessonFormName => $composableBuilder(
      column: $table.lessonFormName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lessonOrder => $composableBuilder(
      column: $table.lessonOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get departmentName => $composableBuilder(
      column: $table.departmentName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get classroomNames => $composableBuilder(
      column: $table.classroomNames,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherNames => $composableBuilder(
      column: $table.teacherNames, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupNames => $composableBuilder(
      column: $table.groupNames, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectName => $composableBuilder(
      column: $table.subjectName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtopic => $composableBuilder(
      column: $table.subtopic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lessonFormName => $composableBuilder(
      column: $table.lessonFormName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lessonOrder => $composableBuilder(
      column: $table.lessonOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get departmentName => $composableBuilder(
      column: $table.departmentName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get classroomNames => $composableBuilder(
      column: $table.classroomNames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherNames => $composableBuilder(
      column: $table.teacherNames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupNames => $composableBuilder(
      column: $table.groupNames, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
      column: $table.subjectName, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get subtopic =>
      $composableBuilder(column: $table.subtopic, builder: (column) => column);

  GeneratedColumn<String> get lessonFormName => $composableBuilder(
      column: $table.lessonFormName, builder: (column) => column);

  GeneratedColumn<int> get lessonOrder => $composableBuilder(
      column: $table.lessonOrder, builder: (column) => column);

  GeneratedColumn<String> get departmentName => $composableBuilder(
      column: $table.departmentName, builder: (column) => column);

  GeneratedColumn<String> get classroomNames => $composableBuilder(
      column: $table.classroomNames, builder: (column) => column);

  GeneratedColumn<String> get teacherNames => $composableBuilder(
      column: $table.teacherNames, builder: (column) => column);

  GeneratedColumn<String> get groupNames => $composableBuilder(
      column: $table.groupNames, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
    Event,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int?> subjectId = const Value.absent(),
            Value<String?> subjectName = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> subtopic = const Value.absent(),
            Value<String?> lessonFormName = const Value.absent(),
            Value<int?> lessonOrder = const Value.absent(),
            Value<String?> departmentName = const Value.absent(),
            Value<String?> classroomNames = const Value.absent(),
            Value<String?> teacherNames = const Value.absent(),
            Value<String?> groupNames = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            startTime: startTime,
            endTime: endTime,
            date: date,
            subjectId: subjectId,
            subjectName: subjectName,
            topic: topic,
            subtopic: subtopic,
            lessonFormName: lessonFormName,
            lessonOrder: lessonOrder,
            departmentName: departmentName,
            classroomNames: classroomNames,
            teacherNames: teacherNames,
            groupNames: groupNames,
            isLocked: isLocked,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String startTime,
            required String endTime,
            required String date,
            Value<int?> subjectId = const Value.absent(),
            Value<String?> subjectName = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> subtopic = const Value.absent(),
            Value<String?> lessonFormName = const Value.absent(),
            Value<int?> lessonOrder = const Value.absent(),
            Value<String?> departmentName = const Value.absent(),
            Value<String?> classroomNames = const Value.absent(),
            Value<String?> teacherNames = const Value.absent(),
            Value<String?> groupNames = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            startTime: startTime,
            endTime: endTime,
            date: date,
            subjectId: subjectId,
            subjectName: subjectName,
            topic: topic,
            subtopic: subtopic,
            lessonFormName: lessonFormName,
            lessonOrder: lessonOrder,
            departmentName: departmentName,
            classroomNames: classroomNames,
            teacherNames: teacherNames,
            groupNames: groupNames,
            isLocked: isLocked,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
    Event,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$TeachersTableTableManager get teachers =>
      $$TeachersTableTableManager(_db, _db.teachers);
  $$ClassroomsTableTableManager get classrooms =>
      $$ClassroomsTableTableManager(_db, _db.classrooms);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
}
