import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

part 'vault_database.g.dart';

/// Encrypted files stored in the vault (photos, videos, documents).
@DataClassName('VaultFileRow')
class VaultFiles extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  TextColumn get name => text()();
  TextColumn get mime => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get createdAt => integer()();
  TextColumn get wrappedDek => text()();
  BoolColumn get hasThumb => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Encrypted-at-rest secret notes (body lives inside the SQLCipher DB).
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Intruder capture events (real namespace only).
@DataClassName('IntruderEventRow')
class IntruderEvents extends Table {
  TextColumn get id => text()();
  IntColumn get timestamp => integer()();
  IntColumn get attemptCount => integer()();
  TextColumn get photoRelPath => text().nullable()();
  TextColumn get wrappedDek => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [VaultFiles, Notes, IntruderEvents])
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Opens an encrypted SQLCipher database at [path] keyed by [hexKey].
  static VaultDatabase open(String path, String hexKey) {
    sqlite_open.open.overrideFor(
      sqlite_open.OperatingSystem.android,
      openCipherOnAndroid,
    );

    final executor = NativeDatabase(
      File(path),
      setup: (raw) {
        raw.execute("PRAGMA key = \"x'$hexKey'\";");
        raw.execute('PRAGMA cipher_page_size = 4096;');
      },
    );
    return VaultDatabase(executor);
  }
}
