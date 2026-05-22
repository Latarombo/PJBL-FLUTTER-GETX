import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppOtpInputTheme {
  static InputDecoration decoration() {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: AppColors.inputBackground,

      // ✅ PENTING: padding biar teks muncul & center
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.outline, width: 2),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.outline, width: 2),
      ),
    );
  }
}
