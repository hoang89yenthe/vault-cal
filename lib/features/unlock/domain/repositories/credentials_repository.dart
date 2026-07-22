import '../../../../core/utils/result.dart';
import '../entities/pin_match.dart';

abstract interface class CredentialsRepository {
  /// Seeds default codes on first run (idempotent).
  Future<void> ensureSeeded();

  Future<bool> verifySecretCode(String code);

  Future<PinMatch> matchPin(String pin);

  /// Verifies [oldCode] then stores [newCode]. Returns [AuthFailure] on
  /// wrong current code.
  Future<Result<void>> changeCode({
    required CodeType type,
    required String oldCode,
    required String newCode,
  });
}
