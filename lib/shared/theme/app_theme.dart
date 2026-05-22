import 'package:flutter/material.dart';

import 'app_input_theme.dart';
import 'app_button_theme.dart';
import 'app_text_theme.dart';
import 'app_card_theme.dart';
import 'app_bottom_nav_theme.dart';
import 'app_color_scheme.dart';
import 'app_icon_theme.dart';

/// AppTheme
/// ----------------------------
/// Theme utama aplikasi
///
/// Menggabungkan seluruh design system:
/// - ColorScheme
/// - Typography
/// - Input
/// - Button
/// - Card
/// - Navigation
/// - Icon
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // color system (Material 3)
    colorScheme: AppColorScheme.light,

    // background
    scaffoldBackgroundColor: AppColorScheme.light.surface,

    // text
    textTheme: AppTextTheme.light,

    // icon
    iconTheme: AppIconTheme.defaultIcon,

    // input
    inputDecorationTheme: AppInputTheme.light,

    // button
    elevatedButtonTheme: AppButtonTheme.elevated,
    outlinedButtonTheme: AppButtonTheme.outlined,

    // card
    cardTheme: AppCardTheme.light,

    // bottom navigation
    bottomNavigationBarTheme: AppBottomNavTheme.light,

    // snackbar base
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),

    // adaptive density
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
