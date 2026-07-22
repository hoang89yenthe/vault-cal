/// Hook invoked when the PIN screen accumulates too many wrong attempts.
///
/// Phase 6 registers a capturing implementation; until then a no-op keeps the
/// unlock flow decoupled from the camera stack.
abstract interface class IntruderTrigger {
  /// Fire-and-forget: must never throw or block the unlock flow.
  void onFailedAttempts(int attemptCount);
}

class NoopIntruderTrigger implements IntruderTrigger {
  const NoopIntruderTrigger();

  @override
  void onFailedAttempts(int attemptCount) {}
}
