import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppColorScheme
/// ----------------------------
/// ColorScheme untuk Material 3
///
/// ⚠️ Beberapa properti belum didefinisikan
/// karena belum ada validasi desain final
class AppColorScheme {
  static final ColorScheme light = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.dark,

    // background: AppColors.background,
    // onBackground: AppColors.textPrimary,

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,

    error: AppColors.error,
    onError: Colors.white,

    // NOTE:
    // secondary, tertiary, outline, dsb
    // belum ditentukan (menunggu validasi UI)
  );
}
