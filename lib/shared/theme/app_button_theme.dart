import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppButtonTheme
/// ----------------------------
/// Mengatur tampilan global tombol
///
/// ⚠️ Catatan penting:
/// - Hierarki tombol (primary / secondary / danger)
///   BELUM ditentukan
/// - Warna disabled & onPrimary
///   BELUM didefinisikan di AppColors
/// - State khusus (loading, success, error)
///   akan ditambahkan setelah flow UX jelas
class AppButtonTheme {
  static ElevatedButtonThemeData elevated = ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.disabled;
        }
        return AppColors.dark;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.onDisabled;
        }
        return AppColors.onDark;
      }),
      minimumSize:
          WidgetStateProperty.all(const Size(double.infinity, 52)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static OutlinedButtonThemeData outlined = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      side: BorderSide(color: AppColors.outline),
      textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  );
}
