import 'package:flutter/material.dart';

import '../../../vault/presentation/theme/vault_colors.dart';

/// Plain-language, honest explanation of what the vault protects — and what it
/// deliberately does not. Radical honesty about limitations is what earns
/// trust with security-conscious users.
class SecurityInfoPage extends StatelessWidget {
  const SecurityInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        foregroundColor: VaultColors.text,
        title: const Text('Bảo mật hoạt động thế nào'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: const [
          _Intro(),
          SizedBox(height: 24),
          _Section(
            icon: Icons.lock_outline,
            title: 'Dữ liệu được mã hoá ra sao',
            body:
                'Mọi ảnh, video, tài liệu và ghi chú được mã hoá bằng AES-256 — '
                'chuẩn mã hoá dùng cho dữ liệu tối mật. Mỗi tệp có một khoá riêng, '
                'và tất cả khoá được bảo vệ bằng kho khoá phần cứng của máy '
                '(Android Keystore / iOS Keychain). Danh sách tệp và ghi chú nằm '
                'trong một cơ sở dữ liệu cũng được mã hoá (SQLCipher).',
          ),
          _Section(
            icon: Icons.theater_comedy_outlined,
            title: 'Kho giả — chống ép buộc',
            body:
                'Nếu bị ép mở khoá, bạn nhập PIN giả. Nó mở ra một kho mồi vô hại '
                'trông như thật, còn kho thật vẫn ẩn. Thời gian mở kho giả và kho '
                'thật giống hệt nhau, nên không thể phân biệt bằng cách bấm giờ.',
          ),
          _Section(
            icon: Icons.phonelink_lock_outlined,
            title: 'Chống rò khi bị nhìn/tịch thu',
            body:
                'Chặn chụp màn hình và quay màn hình (Android), che nội dung khi '
                'chuyển ứng dụng, tự khoá kho khi bạn thoát ra, và xoá mọi dữ liệu '
                'đã giải mã khỏi bộ nhớ khi khoá. Khoá không nằm trong bản sao lưu '
                'nên không thể lấy qua backup.',
          ),
          SizedBox(height: 12),
          _ListCard(
            good: true,
            title: 'Bảo vệ bạn khỏi',
            items: [
              'Mất hoặc bị trộm máy (đang khoá)',
              'Người tò mò cầm máy lên',
              'Bị ép mở khoá (nhờ kho giả)',
              'Chụp lén màn hình / nhìn lén',
              'Trích xuất khoá từ bản sao lưu',
              'Sửa/cắt xén tệp mã hoá (bị phát hiện)',
            ],
          ),
          SizedBox(height: 12),
          _ListCard(
            good: false,
            title: 'KHÔNG bảo vệ khỏi',
            items: [
              'Máy đã bị hack / root / jailbreak (khi kho đang mở, kẻ tấn công đọc được khoá và dữ liệu)',
              'Bị lấy máy đúng lúc kho đang mở',
              'Bị ép lộ PIN thật (kho giả chỉ giúp nếu đối phương không biết có kho thật)',
              'PIN quá đơn giản — 4 số chỉ 10.000 tổ hợp',
              'Trích xuất khoá bằng công cụ forensic cao cấp',
            ],
          ),
          SizedBox(height: 12),
          _Warning(),
          SizedBox(height: 20),
          _Verify(),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VaultColors.accentLight.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VaultColors.accentLight.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: VaultColors.accentLight, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vault Cal chạy hoàn toàn trên máy bạn — không đám mây, không tài '
              'khoản, không gửi dữ liệu đi đâu cả.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: VaultColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: VaultColors.accentLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: VaultColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: VaultColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.good,
    required this.title,
    required this.items,
  });

  final bool good;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final color = good ? VaultColors.green : VaultColors.red;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VaultColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                good ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: VaultColors.text,
                      ),
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

class _Warning extends StatelessWidget {
  const _Warning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VaultColors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultColors.red.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.key_off_outlined, color: VaultColors.red, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không có khôi phục',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: VaultColors.red,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Quên mã bí mật hoặc PIN đồng nghĩa mất dữ liệu vĩnh viễn — '
                  'không có cửa hậu, không reset được. Đây là chủ đích để bảo mật. '
                  'Hãy nhớ kỹ mã của bạn.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: VaultColors.text,
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

class _Verify extends StatelessWidget {
  const _Verify();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kiểm chứng được',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: VaultColors.textSub,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Vault Cal là mã nguồn mở — mọi cơ chế trên đều kiểm tra được trong mã '
          'nguồn. Tài liệu đánh giá mối đe doạ đầy đủ: docs/THREAT-MODEL.md.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: VaultColors.textFaint,
          ),
        ),
      ],
    );
  }
}
