import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppInputTheme
/// ----------------------------
/// File ini bertanggung jawab atas:
/// - Tampilan global TextField / TextFormField
/// - Konsistensi radius, padding, dan warna dasar
///
/// ⚠️ Catatan:
/// - Validasi data BELUM ditentukan
/// - Error message dan penentuan error state
///   akan ditambahkan setelah aturan validasi jelas
class AppInputTheme {
  static InputDecorationTheme light = InputDecorationTheme(
    // Mengaktifkan background fill
    filled: true,

    // Warna dasar input (netral & ramah anak)
    fillColor: AppColors.inputBackground,

    // Border default (idle state)
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppColors.outline, width: 2),
    ),

    // Border saat input aktif
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppColors.accent, width: 2),
      // NOTE:
      // Jika nanti ingin ada highlight focus,
      // tambahkan borderSide di sini
    ),

    // Border saat input enabled tapi tidak fokus
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppColors.outline, width: 2),
    ),

    // Border error
    // ⚠️ DISIAPKAN, tapi belum ditentukan style detail
    // karena aturan validasi belum ada
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),

    // Padding konsisten untuk semua input
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 18,
    ),

    // Hint style default
    hintStyle: TextStyle(
      color: AppColors.textHint,
      fontSize: 14,
    ),

    // NOTE:
    // labelStyle, errorStyle, helperStyle
    // belum ditentukan karena belum ada
    // kebutuhan UX yang jelas
  );
}
