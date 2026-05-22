import 'package:flutter/material.dart';
import '../theme/app_snackbar_theme.dart';

// Enum snack type
enum SnackType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    String? iconPath,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;

    switch (type) {
      case SnackType.success:
        backgroundColor = AppSnackBarTheme.successColor;
        break;
      case SnackType.error:
        backgroundColor = AppSnackBarTheme.errorColor;
        break;
      case SnackType.warning:
        backgroundColor = AppSnackBarTheme.warningColor;
        break;
      case SnackType.info:
        backgroundColor = AppSnackBarTheme.infoColor;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (iconPath != null) ...[
            Image.asset(iconPath, height: 20, width: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: AppSnackBarTheme.textStyle,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: AppSnackBarTheme.shape,
      elevation: AppSnackBarTheme.elevation,
      margin: AppSnackBarTheme.margin,
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
