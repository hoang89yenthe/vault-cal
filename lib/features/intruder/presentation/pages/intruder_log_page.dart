import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../vault/presentation/theme/vault_colors.dart';
import '../../domain/entities/intruder_event.dart';
import '../cubit/intruder_log_cubit.dart';

class IntruderLogPage extends StatelessWidget {
  const IntruderLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IntruderLogCubit>()..load(),
      child: const _IntruderLogView(),
    );
  }
}

class _IntruderLogView extends StatelessWidget {
  const _IntruderLogView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        foregroundColor: VaultColors.text,
        title: const Text('Nhật ký kẻ đột nhập'),
      ),
      body: BlocBuilder<IntruderLogCubit, IntruderLogState>(
        builder: (context, state) {
          return switch (state) {
            IntruderLogLoading() => const LoadingIndicator(),
            IntruderLogError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.read<IntruderLogCubit>().load(),
              ),
            IntruderLogLoaded(:final events) when events.isEmpty => const Center(
                child: Text(
                  'Chưa ghi nhận lần đột nhập nào',
                  style: TextStyle(color: VaultColors.textSub),
                ),
              ),
            IntruderLogLoaded(:final events) => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) =>
                    _EventCard(event: events[index]),
              ),
          };
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final IntruderEvent event;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd/MM HH:mm').format(event.timestamp);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (event.photo != null)
            Image.memory(event.photo!, fit: BoxFit.cover)
          else
            const ColoredBox(
              color: VaultColors.card,
              child: Icon(Icons.no_photography_outlined,
                  color: VaultColors.textFaint),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: VaultColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Sai mã · ${event.attemptCount} lần',
                    style: const TextStyle(fontSize: 10, color: VaultColors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
