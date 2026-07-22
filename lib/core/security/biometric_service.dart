import 'package:local_auth/local_auth.dart';

import '../error/failures.dart';
import '../utils/result.dart';

/// Wraps [LocalAuthentication] so the unlock flow can request real biometrics
/// while the existing scan animation plays.
class BiometricService {
  BiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } on Exception {
      return false;
    }
  }

  Future<Result<bool>> authenticate(String reason) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return Ok(ok);
    } on Exception catch (e) {
      return Err(AuthFailure(e.toString()));
    }
  }
}
