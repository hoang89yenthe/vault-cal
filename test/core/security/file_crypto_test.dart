import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vault_cal/core/security/file_crypto.dart';

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('vlt_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Uint8List randomBytes(int n) {
    final r = Random(42);
    return Uint8List.fromList(List.generate(n, (_) => r.nextInt(256)));
  }

  final dek = Uint8List.fromList(List.generate(32, (i) => i));

  test('round-trips a small file', () async {
    final src = File('${tmp.path}/in.bin')..writeAsBytesSync(randomBytes(1024));
    final enc = '${tmp.path}/out.vlt';

    await FileCrypto.encryptFile(sourcePath: src.path, destPath: enc, dek: dek);
    final decrypted = await FileCrypto.decryptToBytes(
      sourcePath: enc,
      dek: dek,
    );

    expect(decrypted, equals(src.readAsBytesSync()));
  });

  test('round-trips a multi-chunk file (>4MiB) to disk', () async {
    final data = randomBytes(4 * 1024 * 1024 + 12345);
    final src = File('${tmp.path}/big.bin')..writeAsBytesSync(data);
    final enc = '${tmp.path}/big.vlt';
    final dec = '${tmp.path}/big.out';

    await FileCrypto.encryptFile(sourcePath: src.path, destPath: enc, dek: dek);
    await FileCrypto.decryptToFile(sourcePath: enc, destPath: dec, dek: dek);

    expect(File(dec).readAsBytesSync(), equals(data));
  });

  test('round-trips an in-memory buffer', () async {
    final data = randomBytes(50000);
    final enc = '${tmp.path}/mem.vlt';

    await FileCrypto.encryptBytes(bytes: data, destPath: enc, dek: dek);
    final out = await FileCrypto.decryptToBytes(sourcePath: enc, dek: dek);

    expect(out, equals(data));
  });

  test('wrong key fails to decrypt', () async {
    final src = File('${tmp.path}/in.bin')..writeAsBytesSync(randomBytes(2048));
    final enc = '${tmp.path}/out.vlt';
    await FileCrypto.encryptFile(sourcePath: src.path, destPath: enc, dek: dek);

    final wrong = Uint8List.fromList(List.generate(32, (i) => 255 - i));
    expect(
      () => FileCrypto.decryptToBytes(sourcePath: enc, dek: wrong),
      throwsA(anything),
    );
  });
}
