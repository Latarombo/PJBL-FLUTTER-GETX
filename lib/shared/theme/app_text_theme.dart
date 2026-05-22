import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTextTheme
/// ----------------------------
/// Mengatur sistem tipografi global aplikasi
///
/// Prinsip:
/// - Satu font family (Poppins)
/// - Hirarki jelas
/// - Aman dibaca untuk semua umur
///
/// ⚠️ Catatan:
/// - Penggunaan spesifik tiap style
///   (judul soal, skor, timer, dsb)
///   BELUM ditetapkan
/// - Penyesuaian lanjutan akan dilakukan
///   setelah flow UI/UX final
class AppTextTheme {
  static TextTheme light = TextTheme(
    /// Judul besar halaman
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),

    /// Judul section / kartu
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    /// Judul kecil / label penting
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    /// Teks isi utama
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),

    /// Label tombol, tab, dsb
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // NOTE:
    // bodySmall, labelSmall, headlineSmall
    // belum didefinisikan untuk menghindari
    // terlalu banyak variasi tanpa kebutuhan jelas
  );
}
