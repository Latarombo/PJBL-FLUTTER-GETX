import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppIconTheme
/// ----------------------------
/// Konfigurasi icon global aplikasi
///
/// Digunakan sebagai default:
/// - Icon()
/// - IconButton()
///
/// ⚠️ Catatan:
/// - Ukuran spesifik icon (besar/kecil) tetap ditentukan widget
class AppIconTheme {
  static const IconThemeData defaultIcon = IconThemeData(
    color: AppColors.textPrimary,
    size: 24,
  );

  static const IconThemeData muted = IconThemeData(
    color: AppColors.textSecondary,
    size: 20,
  );

  static const IconThemeData active = IconThemeData(
    color: AppColors.dark,
    size: 24,
  );
}
