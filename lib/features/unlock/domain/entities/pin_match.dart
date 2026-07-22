/// Outcome of checking a submitted PIN against stored credentials.
enum PinMatch { none, real, decoy }

/// Which changeable code a change-code flow targets.
enum CodeType { secret, realPin, decoyPin }
