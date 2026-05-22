import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppBottomNavTheme
/// ----------------------------
/// Mengatur tampilan global BottomNavigationBar
///
/// Digunakan untuk:
/// - navigasi utama aplikasi
///
/// ⚠️ Catatan:
/// - Jenis BottomNavigationBar (fixed / shifting)
///   belum diputuskan
/// - Badge, animasi, dan efek khusus
///   akan ditentukan setelah flow navigasi final
class AppBottomNavTheme {
  static BottomNavigationBarThemeData light =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,

    // Warna ikon & label aktif
    selectedItemColor: AppColors.dark,

    // Warna ikon & label tidak aktif
    unselectedItemColor: AppColors.textSecondary,

    // Ukuran ikon
    selectedIconTheme: const IconThemeData(size: 26),
    unselectedIconTheme: const IconThemeData(size: 22),

    // Style label
    selectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),

    // NOTE:
    // showSelectedLabels & showUnselectedLabels
    // tidak diatur di sini karena bergantung
    // pada desain final & jumlah tab
  );
}
