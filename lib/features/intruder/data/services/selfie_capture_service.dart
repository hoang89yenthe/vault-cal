import 'dart:typed_data';

import 'package:camera/camera.dart';

/// Silently captures a single front-camera frame with no preview UI. Entirely
/// best-effort: any failure (no camera, permission denied, OEM quirk) returns
/// null and never throws, so it can never block or reveal the unlock flow.
class SelfieCaptureService {
  Future<Uint8List?> capture() async {
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
      );
      await controller.initialize();
      final file = await controller.takePicture();
      return await file.readAsBytes();
    } on Object {
      return null;
    } finally {
      await controller?.dispose();
    }
  }
}
