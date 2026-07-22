import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/vault_database.dart';
import '../security/key_manager.dart';

/// Single choke point that guarantees real and decoy data never mix.
///
/// [activate] is called exactly once, on PIN success. Every repository reads
/// its namespace, database and directories from here — none ever receives an
/// `isDecoy` flag from the UI.
class VaultSession {
  VaultSession(this._keyManager);

  final KeyManager _keyManager;

  static const String realNamespace = 'real';
  static const String decoyNamespace = 'decoy';

  String? _namespace;
  VaultDatabase? _db;
  String? _root;

  bool get isActive => _namespace != null;
  bool get isDecoy => _namespace == decoyNamespace;

  String get namespace {
    final ns = _namespace;
    if (ns == null) throw StateError('VaultSession not activated');
    return ns;
  }

  VaultDatabase get db {
    final db = _db;
    if (db == null) throw StateError('VaultSession not activated');
    return db;
  }

  /// Opens the database and directory tree for the chosen namespace.
  Future<void> activate({required bool isDecoy}) async {
    await lock();
    final ns = isDecoy ? decoyNamespace : realNamespace;
    _namespace = ns;

    final docs = await getApplicationDocumentsDirectory();
    final root = p.join(docs.path, 'vault', ns);
    _root = root;
    for (final sub in ['media', 'thumbs', 'intruder']) {
      Directory(p.join(root, sub)).createSync(recursive: true);
    }

    final dbPath = p.join(root, 'vault_$ns.db');
    await _keyManager.assertRecoverable(ns, dbExists: File(dbPath).existsSync());
    final key = await _keyManager.databaseKey(ns);
    _db = VaultDatabase.open(dbPath, key);
  }

  String mediaPath(String fileName) => p.join(_root!, 'media', fileName);
  String thumbPath(String fileName) => p.join(_root!, 'thumbs', fileName);
  String intruderPath(String fileName) => p.join(_root!, 'intruder', fileName);

  /// Opens a namespace's database + directory tree without touching the active
  /// session. The caller MUST close the returned database. Used by the intruder
  /// recorder, which fires before the user has authenticated.
  static Future<({VaultDatabase db, String root})> openStandalone(
    KeyManager keyManager,
    String namespace,
  ) async {
    final docs = await getApplicationDocumentsDirectory();
    final root = p.join(docs.path, 'vault', namespace);
    for (final sub in ['media', 'thumbs', 'intruder']) {
      Directory(p.join(root, sub)).createSync(recursive: true);
    }
    final key = await keyManager.databaseKey(namespace);
    final db = VaultDatabase.open(p.join(root, 'vault_$namespace.db'), key);
    return (db: db, root: root);
  }

  /// Closes the database and clears state. Called on app background / lock.
  Future<void> lock() async {
    await _db?.close();
    _db = null;
    _namespace = null;
    _root = null;
  }
}
