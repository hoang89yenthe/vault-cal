import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/result.dart';
import '../../../intruder/domain/entities/intruder_event.dart';
import '../../../intruder/domain/repositories/intruder_repository.dart';
import '../../../unlock/domain/entities/pin_match.dart';
import '../../../vault/presentation/theme/vault_colors.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/paywall_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: VaultColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: VaultColors.cardBorder),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: VaultColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      l10n.settingsTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: VaultColors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _PremiumCta(onTap: () => showPaywall(context)),
                const SizedBox(height: 24),
                _SectionLabel(l10n.sectionSecurity),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.shield_outlined,
                      tone: folderTone(200),
                      title: 'Bảo mật hoạt động thế nào',
                      trailing: const _Chevron(),
                      onTap: () => context.push(AppRoutes.securityInfo),
                    ),
                    const _RowDivider(),
                    _SettingsRow(
                      icon: Icons.pin_outlined,
                      tone: folderTone(255),
                      title: l10n.changeSecretCode,
                      trailing: const _Chevron(),
                      onTap: () => context.push(
                        '${AppRoutes.changeCode}/${CodeType.secret.name}',
                      ),
                    ),
                    const _RowDivider(),
                    _SettingsRow(
                      icon: Icons.key_outlined,
                      tone: folderTone(150),
                      title: l10n.changeRealPassword,
                      trailing: const _Chevron(),
                      onTap: () => context.push(
                        '${AppRoutes.changeCode}/${CodeType.realPin.name}',
                      ),
                    ),
                    const _RowDivider(),
                    _SettingsRow(
                      icon: Icons.theater_comedy_outlined,
                      tone: folderTone(305),
                      title: state.decoyPinSet
                          ? l10n.changeFakePassword
                          : 'Thiết lập kho giả (chống ép buộc)',
                      subtitle: state.decoyPinSet
                          ? null
                          : 'PIN mở một kho mồi vô hại khi bạn bị ép mở',
                      trailing: const _Chevron(),
                      onTap: () async {
                        final suffix = state.decoyPinSet ? '' : '?firstTime=1';
                        await context.push(
                          '${AppRoutes.changeCode}/${CodeType.decoyPin.name}$suffix',
                        );
                        if (context.mounted) cubit.refreshDecoy();
                      },
                    ),
                    const _RowDivider(),
                    _SettingsRow(
                      icon: Icons.fingerprint,
                      tone: folderTone(255),
                      title: l10n.fingerprintUnlock,
                      trailing: _Toggle(
                        value: state.fingerprint,
                        onChanged: (_) => cubit.toggleFingerprint(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(l10n.sectionIntruder),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.camera_alt_outlined,
                      tone: folderTone(25),
                      title: l10n.intruderSelfie,
                      titleBadge: const Icon(
                        Icons.workspace_premium,
                        size: 16,
                        color: VaultColors.gold,
                      ),
                      subtitle: l10n.intruderSelfieSub,
                      trailing: _Toggle(
                        value: state.intruder,
                        onChanged: (_) async {
                          final wasOff = !state.intruder;
                          if (!cubit.tryToggleIntruder()) {
                            showPaywall(context);
                          } else if (wasOff) {
                            await Permission.camera.request();
                          }
                        },
                      ),
                    ),
                    const _RowDivider(),
                    InkWell(
                      onTap: () => context.push(AppRoutes.intruderLog),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.intruderLog,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: VaultColors.textSub,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: VaultColors.textFaint,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const _IntruderLog(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(l10n.sectionDisguise),
                _SettingsCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.changeDisguiseIcon,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: VaultColors.text,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _DisguiseOption(
                                icon: Icons.calculate_outlined,
                                label: l10n.iconCalc,
                                selected: state.disguise == DisguiseIcon.calc,
                                premiumLocked: false,
                                onTap: () =>
                                    cubit.trySelectDisguise(DisguiseIcon.calc),
                              ),
                              _DisguiseOption(
                                icon: Icons.wb_sunny_outlined,
                                label: l10n.iconWeather,
                                selected:
                                    state.disguise == DisguiseIcon.weather,
                                premiumLocked: !state.premium,
                                onTap: () {
                                  if (!cubit.trySelectDisguise(
                                    DisguiseIcon.weather,
                                  )) {
                                    showPaywall(context);
                                  }
                                },
                              ),
                              _DisguiseOption(
                                icon: Icons.explore_outlined,
                                label: l10n.iconCompass,
                                selected:
                                    state.disguise == DisguiseIcon.compass,
                                premiumLocked: !state.premium,
                                onTap: () {
                                  if (!cubit.trySelectDisguise(
                                    DisguiseIcon.compass,
                                  )) {
                                    showPaywall(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumCta extends StatelessWidget {
  const _PremiumCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VaultColors.premiumCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: VaultColors.premiumCardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: VaultColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 24,
                color: VaultColors.gold,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.premiumTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: VaultColors.gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.premiumSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: VaultColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: VaultColors.gold),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: VaultColors.textSub,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VaultColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: VaultColors.divider);
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chevron_right,
      size: 20,
      color: VaultColors.textFaint,
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: VaultColors.accent,
      inactiveTrackColor: VaultColors.progressTrack,
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.trailing,
    this.titleBadge,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final ({Color bg, Color fg}) tone;
  final String title;
  final Widget? titleBadge;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tone.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: tone.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: VaultColors.text,
                          ),
                        ),
                      ),
                      if (titleBadge != null) ...[
                        const SizedBox(width: 6),
                        titleBadge!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: VaultColors.textSub,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

/// Live preview of the most recent real intruder captures. Shows an empty
/// state until an actual break-in is recorded.
class _IntruderLog extends StatefulWidget {
  const _IntruderLog();

  @override
  State<_IntruderLog> createState() => _IntruderLogState();
}

class _IntruderLogState extends State<_IntruderLog> {
  List<IntruderEvent>? _events;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<IntruderRepository>().listEvents();
    if (!mounted) return;
    setState(() {
      _events = switch (result) {
        Ok(:final value) => value,
        Err() => const [],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    if (events == null) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (events.isEmpty) {
      return const SizedBox(
        height: 44,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Chưa ghi nhận lần đột nhập nào',
            style: TextStyle(fontSize: 12, color: VaultColors.textFaint),
          ),
        ),
      );
    }
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final event = events[index];
          final time = DateFormat('dd/MM HH:mm').format(event.timestamp);
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.photo != null)
                    Image.memory(event.photo!, fit: BoxFit.cover)
                  else
                    const ColoredBox(
                      color: VaultColors.card,
                      child: Icon(
                        Icons.no_photography_outlined,
                        color: VaultColors.textFaint,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: VaultColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            'Sai mã · ${event.attemptCount} lần',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: VaultColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DisguiseOption extends StatelessWidget {
  const _DisguiseOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.premiumLocked,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool premiumLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: VaultColors.background,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected ? VaultColors.green : VaultColors.cardBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Icon(icon, size: 26, color: VaultColors.text),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: VaultColors.textSub),
            ),
            const SizedBox(height: 4),
            if (selected)
              const Icon(Icons.check_circle, size: 16, color: VaultColors.green)
            else if (premiumLocked)
              const Icon(
                Icons.workspace_premium,
                size: 16,
                color: VaultColors.gold,
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
