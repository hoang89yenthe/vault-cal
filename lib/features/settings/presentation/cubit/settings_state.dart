part of 'settings_cubit.dart';

enum DisguiseIcon { calc, weather, compass }

class SettingsState extends Equatable {
  const SettingsState({
    this.fingerprint = true,
    this.intruder = false,
    this.disguise = DisguiseIcon.calc,
    this.premium = false,
    this.decoyPinSet = false,
  });

  final bool fingerprint;
  final bool intruder;
  final DisguiseIcon disguise;
  final bool premium;
  final bool decoyPinSet;

  SettingsState copyWith({
    bool? fingerprint,
    bool? intruder,
    DisguiseIcon? disguise,
    bool? premium,
    bool? decoyPinSet,
  }) {
    return SettingsState(
      fingerprint: fingerprint ?? this.fingerprint,
      intruder: intruder ?? this.intruder,
      disguise: disguise ?? this.disguise,
      premium: premium ?? this.premium,
      decoyPinSet: decoyPinSet ?? this.decoyPinSet,
    );
  }

  @override
  List<Object?> get props => [
    fingerprint,
    intruder,
    disguise,
    premium,
    decoyPinSet,
  ];
}
