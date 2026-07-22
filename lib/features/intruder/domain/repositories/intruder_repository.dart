import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../entities/intruder_event.dart';

abstract interface class IntruderRepository {
  /// Encrypts [photo] (may be null) and records an intruder event in the real
  /// namespace, independent of any active session.
  Future<void> record({required int attemptCount, Uint8List? photo});

  Future<Result<List<IntruderEvent>>> listEvents();
}
