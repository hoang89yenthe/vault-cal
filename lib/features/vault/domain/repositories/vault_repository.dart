import '../../../../core/utils/result.dart';
import '../entities/vault_data.dart';

abstract interface class VaultRepository {
  /// Loads the dashboard for the currently active vault session
  /// (real vs decoy is carried by VaultSession, not passed in).
  Future<Result<VaultData>> getVault();
}
