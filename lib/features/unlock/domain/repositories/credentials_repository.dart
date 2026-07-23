import '../../../../core/utils/result.dart';
import '../entities/pin_match.dart';

abstract interface class CredentialsRepository {
  /// True once the user has set their own codes via onboarding.
  Future<bool> isInitialized();

  /// Stores the user-chosen codes on first-run onboarding and marks the
  /// vault initialized. There are no default/seeded codes.
  Future<void> initialize({
    required String secret,
    required String realPin,
    required String decoyPin,
  });

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
