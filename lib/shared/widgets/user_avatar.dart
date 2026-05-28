import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';

/// Widget avatar yang reaktif — otomatis update di semua halaman
/// saat localAvatarPath di AuthController berubah.
///
/// Penggunaan:
///   UserAvatar(size: 96)               // default
///   UserAvatar(size: 40, border: 2)    // kecil untuk header
class UserAvatar extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color borderColor;

  const UserAvatar({
    super.key,
    this.size = 96,
    this.borderWidth = 3,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final localPath = authController.localAvatarPath.value;

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: localPath != null
              // ── Foto dari galeri (file lokal) ──────────────────────
              ? Image.file(
                  File(localPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallback(),
                )
              // ── Fallback: asset default ────────────────────────────
              : Image.asset(
                  'assets/images/user.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallback(),
                ),
        ),
      );
    });
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFFFC4D6),
      child: Icon(
        Icons.person,
        color: const Color(0xFF8B4789),
        size: size * 0.5,
      ),
    );
  }
}
