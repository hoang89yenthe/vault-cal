import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class IntruderEvent extends Equatable {
  const IntruderEvent({
    required this.id,
    required this.timestamp,
    required this.attemptCount,
    this.photo,
  });

  final String id;
  final DateTime timestamp;
  final int attemptCount;

  /// Decrypted selfie bytes, or null if capture failed / no camera.
  final Uint8List? photo;

  @override
  List<Object?> get props => [id, timestamp, attemptCount, photo];
}
