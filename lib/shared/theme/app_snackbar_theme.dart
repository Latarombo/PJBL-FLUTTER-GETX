import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppSnackBarTheme
/// ----------------------------
/// Konfigurasi visual dasar SnackBar
///
/// Digunakan oleh:
/// - AppSnackBar (widget helper)
///
/// ⚠️ Catatan:
/// - Layout (Row, Icon, dsb) ditangani oleh widget
/// - Animasi & behavior belum didefinisikan
class AppSnackBarTheme {
  // Shape default
  static final ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  // Text style default
  static const TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Elevation default
  static const double elevation = 6;

  // Margin (floating snackbar)
  static const EdgeInsets margin = EdgeInsets.all(16);

  // Background color berdasarkan tipe
  static const Color successColor = AppColors.success;
  static const Color errorColor = AppColors.error;
  static const Color warningColor = AppColors.warning;
  static const Color infoColor = AppColors.info;

  // NOTE:
  // Duration & position (floating/fixed)
  // ditentukan oleh pemanggil widget
}
