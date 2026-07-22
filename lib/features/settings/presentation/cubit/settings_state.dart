part of 'settings_cubit.dart';

enum DisguiseIcon { calc, weather, compass }

class SettingsState extends Equatable {
  const SettingsState({
    this.fingerprint = true,
    this.intruder = false,
    this.disguise = DisguiseIcon.calc,
    this.premium = false,
  });

  final bool fingerprint;
  final bool intruder;
  final DisguiseIcon disguise;
  final bool premium;

  SettingsState copyWith({
    bool? fingerprint,
    bool? intruder,
    DisguiseIcon? disguise,
    bool? premium,
  }) {
    return SettingsState(
      fingerprint: fingerprint ?? this.fingerprint,
      intruder: intruder ?? this.intruder,
      disguise: disguise ?? this.disguise,
      premium: premium ?? this.premium,
    );
  }

  @override
  List<Object?> get props => [fingerprint, intruder, disguise, premium];
}
