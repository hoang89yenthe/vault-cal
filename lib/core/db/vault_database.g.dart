// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_database.dart';

// ignore_for_file: type=lint
class $VaultFilesTable extends VaultFiles
    with TableInfo<$VaultFilesTable, VaultFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrappedDekMeta = const VerificationMeta(
    'wrappedDek',
  );
  @override
  late final GeneratedColumn<String> wrappedDek = GeneratedColumn<String>(
    'wrapped_dek',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasThumbMeta = const VerificationMeta(
    'hasThumb',
  );
  @override
  late final GeneratedColumn<bool> hasThumb = GeneratedColumn<bool>(
    'has_thumb',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_thumb" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    name,
    mime,
    sizeBytes,
    createdAt,
    wrappedDek,
    hasThumb,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('wrapped_dek')) {
      context.handle(
        _wrappedDekMeta,
        wrappedDek.isAcceptableOrUnknown(data['wrapped_dek']!, _wrappedDekMeta),
      );
    } else if (isInserting) {
      context.missing(_wrappedDekMeta);
    }
    if (data.containsKey('has_thumb')) {
      context.handle(
        _hasThumbMeta,
        hasThumb.isAcceptableOrUnknown(data['has_thumb']!, _hasThumbMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultFileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      wrappedDek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wrapped_dek'],
      )!,
      hasThumb: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_thumb'],
      )!,
    );
  }

  @override
  $VaultFilesTable createAlias(String alias) {
    return $VaultFilesTable(attachedDatabase, alias);
  }
}

class VaultFileRow extends DataClass implements Insertable<VaultFileRow> {
  final String id;
  final String category;
  final String name;
  final String mime;
  final int sizeBytes;
  final int createdAt;
  final String wrappedDek;
  final bool hasThumb;
  const VaultFileRow({
    required this.id,
    required this.category,
    required this.name,
    required this.mime,
    required this.sizeBytes,
    required this.createdAt,
    required this.wrappedDek,
    required this.hasThumb,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['name'] = Variable<String>(name);
    map['mime'] = Variable<String>(mime);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<int>(createdAt);
    map['wrapped_dek'] = Variable<String>(wrappedDek);
    map['has_thumb'] = Variable<bool>(hasThumb);
    return map;
  }

  VaultFilesCompanion toCompanion(bool nullToAbsent) {
    return VaultFilesCompanion(
      id: Value(id),
      category: Value(category),
      name: Value(name),
      mime: Value(mime),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
      wrappedDek: Value(wrappedDek),
      hasThumb: Value(hasThumb),
    );
  }

  factory VaultFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultFileRow(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      name: serializer.fromJson<String>(json['name']),
      mime: serializer.fromJson<String>(json['mime']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      wrappedDek: serializer.fromJson<String>(json['wrappedDek']),
      hasThumb: serializer.fromJson<bool>(json['hasThumb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'name': serializer.toJson<String>(name),
      'mime': serializer.toJson<String>(mime),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<int>(createdAt),
      'wrappedDek': serializer.toJson<String>(wrappedDek),
      'hasThumb': serializer.toJson<bool>(hasThumb),
    };
  }

  VaultFileRow copyWith({
    String? id,
    String? category,
    String? name,
    String? mime,
    int? sizeBytes,
    int? createdAt,
    String? wrappedDek,
    bool? hasThumb,
  }) => VaultFileRow(
    id: id ?? this.id,
    category: category ?? this.category,
    name: name ?? this.name,
    mime: mime ?? this.mime,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    wrappedDek: wrappedDek ?? this.wrappedDek,
    hasThumb: hasThumb ?? this.hasThumb,
  );
  VaultFileRow copyWithCompanion(VaultFilesCompanion data) {
    return VaultFileRow(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      name: data.name.present ? data.name.value : this.name,
      mime: data.mime.present ? data.mime.value : this.mime,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      wrappedDek: data.wrappedDek.present
          ? data.wrappedDek.value
          : this.wrappedDek,
      hasThumb: data.hasThumb.present ? data.hasThumb.value : this.hasThumb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultFileRow(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('wrappedDek: $wrappedDek, ')
          ..write('hasThumb: $hasThumb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    name,
    mime,
    sizeBytes,
    createdAt,
    wrappedDek,
    hasThumb,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultFileRow &&
          other.id == this.id &&
          other.category == this.category &&
          other.name == this.name &&
          other.mime == this.mime &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.wrappedDek == this.wrappedDek &&
          other.hasThumb == this.hasThumb);
}

class VaultFilesCompanion extends UpdateCompanion<VaultFileRow> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> name;
  final Value<String> mime;
  final Value<int> sizeBytes;
  final Value<int> createdAt;
  final Value<String> wrappedDek;
  final Value<bool> hasThumb;
  final Value<int> rowid;
  const VaultFilesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.name = const Value.absent(),
    this.mime = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.wrappedDek = const Value.absent(),
    this.hasThumb = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultFilesCompanion.insert({
    required String id,
    required String category,
    required String name,
    required String mime,
    required int sizeBytes,
    required int createdAt,
    required String wrappedDek,
    this.hasThumb = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       name = Value(name),
       mime = Value(mime),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt),
       wrappedDek = Value(wrappedDek);
  static Insertable<VaultFileRow> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? name,
    Expression<String>? mime,
    Expression<int>? sizeBytes,
    Expression<int>? createdAt,
    Expression<String>? wrappedDek,
    Expression<bool>? hasThumb,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (name != null) 'name': name,
      if (mime != null) 'mime': mime,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (wrappedDek != null) 'wrapped_dek': wrappedDek,
      if (hasThumb != null) 'has_thumb': hasThumb,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<String>? name,
    Value<String>? mime,
    Value<int>? sizeBytes,
    Value<int>? createdAt,
    Value<String>? wrappedDek,
    Value<bool>? hasThumb,
    Value<int>? rowid,
  }) {
    return VaultFilesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      wrappedDek: wrappedDek ?? this.wrappedDek,
      hasThumb: hasThumb ?? this.hasThumb,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (wrappedDek.present) {
      map['wrapped_dek'] = Variable<String>(wrappedDek.value);
    }
    if (hasThumb.present) {
      map['has_thumb'] = Variable<bool>(hasThumb.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultFilesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('wrappedDek: $wrappedDek, ')
          ..write('hasThumb: $hasThumb, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, body, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String title;
  final String body;
  final int createdAt;
  final int updatedAt;
  const NoteRow({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NoteRow copyWith({
    String? id,
    String? title,
    String? body,
    int? createdAt,
    int? updatedAt,
  }) => NoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, body, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> body;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String title,
    required String body,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? body,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntruderEventsTable extends IntruderEvents
    with TableInfo<$IntruderEventsTable, IntruderEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntruderEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoRelPathMeta = const VerificationMeta(
    'photoRelPath',
  );
  @override
  late final GeneratedColumn<String> photoRelPath = GeneratedColumn<String>(
    'photo_rel_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wrappedDekMeta = const VerificationMeta(
    'wrappedDek',
  );
  @override
  late final GeneratedColumn<String> wrappedDek = GeneratedColumn<String>(
    'wrapped_dek',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    attemptCount,
    photoRelPath,
    wrappedDek,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intruder_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntruderEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptCountMeta);
    }
    if (data.containsKey('photo_rel_path')) {
      context.handle(
        _photoRelPathMeta,
        photoRelPath.isAcceptableOrUnknown(
          data['photo_rel_path']!,
          _photoRelPathMeta,
        ),
      );
    }
    if (data.containsKey('wrapped_dek')) {
      context.handle(
        _wrappedDekMeta,
        wrappedDek.isAcceptableOrUnknown(data['wrapped_dek']!, _wrappedDekMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntruderEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntruderEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      photoRelPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_rel_path'],
      ),
      wrappedDek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wrapped_dek'],
      ),
    );
  }

  @override
  $IntruderEventsTable createAlias(String alias) {
    return $IntruderEventsTable(attachedDatabase, alias);
  }
}

class IntruderEventRow extends DataClass
    implements Insertable<IntruderEventRow> {
  final String id;
  final int timestamp;
  final int attemptCount;
  final String? photoRelPath;
  final String? wrappedDek;
  const IntruderEventRow({
    required this.id,
    required this.timestamp,
    required this.attemptCount,
    this.photoRelPath,
    this.wrappedDek,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<int>(timestamp);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || photoRelPath != null) {
      map['photo_rel_path'] = Variable<String>(photoRelPath);
    }
    if (!nullToAbsent || wrappedDek != null) {
      map['wrapped_dek'] = Variable<String>(wrappedDek);
    }
    return map;
  }

  IntruderEventsCompanion toCompanion(bool nullToAbsent) {
    return IntruderEventsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      attemptCount: Value(attemptCount),
      photoRelPath: photoRelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoRelPath),
      wrappedDek: wrappedDek == null && nullToAbsent
          ? const Value.absent()
          : Value(wrappedDek),
    );
  }

  factory IntruderEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntruderEventRow(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      photoRelPath: serializer.fromJson<String?>(json['photoRelPath']),
      wrappedDek: serializer.fromJson<String?>(json['wrappedDek']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<int>(timestamp),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'photoRelPath': serializer.toJson<String?>(photoRelPath),
      'wrappedDek': serializer.toJson<String?>(wrappedDek),
    };
  }

  IntruderEventRow copyWith({
    String? id,
    int? timestamp,
    int? attemptCount,
    Value<String?> photoRelPath = const Value.absent(),
    Value<String?> wrappedDek = const Value.absent(),
  }) => IntruderEventRow(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    attemptCount: attemptCount ?? this.attemptCount,
    photoRelPath: photoRelPath.present ? photoRelPath.value : this.photoRelPath,
    wrappedDek: wrappedDek.present ? wrappedDek.value : this.wrappedDek,
  );
  IntruderEventRow copyWithCompanion(IntruderEventsCompanion data) {
    return IntruderEventRow(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      photoRelPath: data.photoRelPath.present
          ? data.photoRelPath.value
          : this.photoRelPath,
      wrappedDek: data.wrappedDek.present
          ? data.wrappedDek.value
          : this.wrappedDek,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntruderEventRow(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('photoRelPath: $photoRelPath, ')
          ..write('wrappedDek: $wrappedDek')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timestamp, attemptCount, photoRelPath, wrappedDek);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntruderEventRow &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.attemptCount == this.attemptCount &&
          other.photoRelPath == this.photoRelPath &&
          other.wrappedDek == this.wrappedDek);
}

class IntruderEventsCompanion extends UpdateCompanion<IntruderEventRow> {
  final Value<String> id;
  final Value<int> timestamp;
  final Value<int> attemptCount;
  final Value<String?> photoRelPath;
  final Value<String?> wrappedDek;
  final Value<int> rowid;
  const IntruderEventsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.photoRelPath = const Value.absent(),
    this.wrappedDek = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntruderEventsCompanion.insert({
    required String id,
    required int timestamp,
    required int attemptCount,
    this.photoRelPath = const Value.absent(),
    this.wrappedDek = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestamp = Value(timestamp),
       attemptCount = Value(attemptCount);
  static Insertable<IntruderEventRow> custom({
    Expression<String>? id,
    Expression<int>? timestamp,
    Expression<int>? attemptCount,
    Expression<String>? photoRelPath,
    Expression<String>? wrappedDek,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (photoRelPath != null) 'photo_rel_path': photoRelPath,
      if (wrappedDek != null) 'wrapped_dek': wrappedDek,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntruderEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? timestamp,
    Value<int>? attemptCount,
    Value<String?>? photoRelPath,
    Value<String?>? wrappedDek,
    Value<int>? rowid,
  }) {
    return IntruderEventsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      attemptCount: attemptCount ?? this.attemptCount,
      photoRelPath: photoRelPath ?? this.photoRelPath,
      wrappedDek: wrappedDek ?? this.wrappedDek,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (photoRelPath.present) {
      map['photo_rel_path'] = Variable<String>(photoRelPath.value);
    }
    if (wrappedDek.present) {
      map['wrapped_dek'] = Variable<String>(wrappedDek.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntruderEventsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('photoRelPath: $photoRelPath, ')
          ..write('wrappedDek: $wrappedDek, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $VaultFilesTable vaultFiles = $VaultFilesTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $IntruderEventsTable intruderEvents = $IntruderEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vaultFiles,
    notes,
    intruderEvents,
  ];
}

typedef $$VaultFilesTableCreateCompanionBuilder =
    VaultFilesCompanion Function({
      required String id,
      required String category,
      required String name,
      required String mime,
      required int sizeBytes,
      required int createdAt,
      required String wrappedDek,
      Value<bool> hasThumb,
      Value<int> rowid,
    });
typedef $$VaultFilesTableUpdateCompanionBuilder =
    VaultFilesCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<String> name,
      Value<String> mime,
      Value<int> sizeBytes,
      Value<int> createdAt,
      Value<String> wrappedDek,
      Value<bool> hasThumb,
      Value<int> rowid,
    });

class $$VaultFilesTableFilterComposer
    extends Composer<_$VaultDatabase, $VaultFilesTable> {
  $$VaultFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wrappedDek => $composableBuilder(
    column: $table.wrappedDek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasThumb => $composableBuilder(
    column: $table.hasThumb,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultFilesTableOrderingComposer
    extends Composer<_$VaultDatabase, $VaultFilesTable> {
  $$VaultFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wrappedDek => $composableBuilder(
    column: $table.wrappedDek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasThumb => $composableBuilder(
    column: $table.hasThumb,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultFilesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $VaultFilesTable> {
  $$VaultFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get wrappedDek => $composableBuilder(
    column: $table.wrappedDek,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasThumb =>
      $composableBuilder(column: $table.hasThumb, builder: (column) => column);
}

class $$VaultFilesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $VaultFilesTable,
          VaultFileRow,
          $$VaultFilesTableFilterComposer,
          $$VaultFilesTableOrderingComposer,
          $$VaultFilesTableAnnotationComposer,
          $$VaultFilesTableCreateCompanionBuilder,
          $$VaultFilesTableUpdateCompanionBuilder,
          (
            VaultFileRow,
            BaseReferences<_$VaultDatabase, $VaultFilesTable, VaultFileRow>,
          ),
          VaultFileRow,
          PrefetchHooks Function()
        > {
  $$VaultFilesTableTableManager(_$VaultDatabase db, $VaultFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> wrappedDek = const Value.absent(),
                Value<bool> hasThumb = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultFilesCompanion(
                id: id,
                category: category,
                name: name,
                mime: mime,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                wrappedDek: wrappedDek,
                hasThumb: hasThumb,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required String name,
                required String mime,
                required int sizeBytes,
                required int createdAt,
                required String wrappedDek,
                Value<bool> hasThumb = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultFilesCompanion.insert(
                id: id,
                category: category,
                name: name,
                mime: mime,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                wrappedDek: wrappedDek,
                hasThumb: hasThumb,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $VaultFilesTable,
      VaultFileRow,
      $$VaultFilesTableFilterComposer,
      $$VaultFilesTableOrderingComposer,
      $$VaultFilesTableAnnotationComposer,
      $$VaultFilesTableCreateCompanionBuilder,
      $$VaultFilesTableUpdateCompanionBuilder,
      (
        VaultFileRow,
        BaseReferences<_$VaultDatabase, $VaultFilesTable, VaultFileRow>,
      ),
      VaultFileRow,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String title,
      required String body,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> body,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$NotesTableFilterComposer
    extends Composer<_$VaultDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$VaultDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$VaultDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$VaultDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String body,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$VaultDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;
typedef $$IntruderEventsTableCreateCompanionBuilder =
    IntruderEventsCompanion Function({
      required String id,
      required int timestamp,
      required int attemptCount,
      Value<String?> photoRelPath,
      Value<String?> wrappedDek,
      Value<int> rowid,
    });
typedef $$IntruderEventsTableUpdateCompanionBuilder =
    IntruderEventsCompanion Function({
      Value<String> id,
      Value<int> timestamp,
      Value<int> attemptCount,
      Value<String?> photoRelPath,
      Value<String?> wrappedDek,
      Value<int> rowid,
    });

class $$IntruderEventsTableFilterComposer
    extends Composer<_$VaultDatabase, $IntruderEventsTable> {
  $$IntruderEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoRelPath => $composableBuilder(
    column: $table.photoRelPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wrappedDek => $composableBuilder(
    column: $table.wrappedDek,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IntruderEventsTableOrderingComposer
    extends Composer<_$VaultDatabase, $IntruderEventsTable> {
  $$IntruderEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoRelPath => $composableBuilder(
    column: $table.photoRelPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wrappedDek => $composableBuilder(
    column: $table.wrappedDek,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IntruderEventsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $IntruderEventsTable> {
  $$IntruderEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoRelPath => $composableBuilder(
    column: $table.photoRelPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wrappedDek => $composableBuilder(
    column: $table.wrappedDek,
    builder: (column) => column,
  );
}

class $$IntruderEventsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $IntruderEventsTable,
          IntruderEventRow,
          $$IntruderEventsTableFilterComposer,
          $$IntruderEventsTableOrderingComposer,
          $$IntruderEventsTableAnnotationComposer,
          $$IntruderEventsTableCreateCompanionBuilder,
          $$IntruderEventsTableUpdateCompanionBuilder,
          (
            IntruderEventRow,
            BaseReferences<
              _$VaultDatabase,
              $IntruderEventsTable,
              IntruderEventRow
            >,
          ),
          IntruderEventRow,
          PrefetchHooks Function()
        > {
  $$IntruderEventsTableTableManager(
    _$VaultDatabase db,
    $IntruderEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntruderEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntruderEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntruderEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> photoRelPath = const Value.absent(),
                Value<String?> wrappedDek = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntruderEventsCompanion(
                id: id,
                timestamp: timestamp,
                attemptCount: attemptCount,
                photoRelPath: photoRelPath,
                wrappedDek: wrappedDek,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int timestamp,
                required int attemptCount,
                Value<String?> photoRelPath = const Value.absent(),
                Value<String?> wrappedDek = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntruderEventsCompanion.insert(
                id: id,
                timestamp: timestamp,
                attemptCount: attemptCount,
                photoRelPath: photoRelPath,
                wrappedDek: wrappedDek,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IntruderEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $IntruderEventsTable,
      IntruderEventRow,
      $$IntruderEventsTableFilterComposer,
      $$IntruderEventsTableOrderingComposer,
      $$IntruderEventsTableAnnotationComposer,
      $$IntruderEventsTableCreateCompanionBuilder,
      $$IntruderEventsTableUpdateCompanionBuilder,
      (
        IntruderEventRow,
        BaseReferences<_$VaultDatabase, $IntruderEventsTable, IntruderEventRow>,
      ),
      IntruderEventRow,
      PrefetchHooks Function()
    >;

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$VaultFilesTableTableManager get vaultFiles =>
      $$VaultFilesTableTableManager(_db, _db.vaultFiles);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$IntruderEventsTableTableManager get intruderEvents =>
      $$IntruderEventsTableTableManager(_db, _db.intruderEvents);
}
