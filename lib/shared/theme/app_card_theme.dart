import 'package:flutter/material.dart';

/// AppCardTheme
/// ----------------------------
/// Theme global untuk Card
///
/// ⚠️ Catatan:
/// - Elevation & warna masih basic
/// - Akan disesuaikan setelah hierarchy konten final
class AppCardTheme {
  static CardThemeData light = CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
