import 'package:flutter/material.dart';

/// AppColors
/// ----------------------------
/// Sistem warna terpusat untuk seluruh aplikasi
/// Ubah warna di sini untuk apply ke semua halaman
class AppColors {
  // ============================================
  // BACKGROUND COLORS - UBAH DI SINI
  // ============================================
  
  /// Background utama aplikasi (cream)
  /// Digunakan di: HomePage, LeaderboardPage, SettingsPage, dll
  static const background = Color(0xFFF9F4E4);
  
  /// Background alternatif (jika butuh variasi)
  static const backgroundAlt = Color(0xFFFFF8E7);
  
  /// Surface color untuk cards
  static final surface = Colors.grey[300]!;
  
  /// Surface putih untuk cards/containers
  static const surfaceWhite = Colors.white;

  /// Background untuk input fields
  static const inputBackground = Color.fromARGB(255, 247, 247, 247);


  // ============================================
  // BRAND COLORS
  // ============================================
  
  static const primary = Color(0xfff9f4e4);
  static const onPrimary = Color(0xffffffff);

  // ============================================
  // TEXT COLORS
  // ============================================
  
  static const textPrimary = Color(0xff270f0f);
  static const textSecondary = Color(0xffffffff);
  static const textDisabled = Color(0xFF9E9E9E);
  static final textHint = Colors.grey[600]!;
  static final textDialog = Colors.grey[700];
  
  // ============================================
  // NEUTRAL / DARK
  // ============================================
  
  /// Warna primary button
  static const dark = Color(0xFF1A2332);
  /// Warna teks on primary button
  static const onDark = Colors.white;
  // Warna tombol Secondary
  static const light =Color(0xFFFFDDB3);
  // Warna text on secondary button
  static const onLight = Color(0xff270f0f);

  // ============================================
  // ACCENT COLORS
  // ============================================
  
  static const danger = Color(0xFFD32F2F);
  static const onDanger = Colors.white;
  
  /// Progress bar, badges
  static const accent = Color(0xFFFFB347); // Orange
  
  /// Featured card gradient
  static const accentGreen = Color(0xFF5A8B7E);
  static const accentGreenDark = Color(0xFF4A7A6D);

  // ============================================
  // BORDERS & OUTLINES
  // ============================================
  
  static const outline = Color(0xFFDDDDDD);
  static const disabled = Color(0xFFE0E0E0);
  static const onDisabled = Color(0xFF9E9E9E);

  // ============================================
  // FEEDBACK COLORS (Sementara)
  // ============================================
  
  static const error = Colors.red;
  static const warning = Colors.orange;
  static const success = Colors.green;
  static const info = Colors.blue;

  // ============================================
  // SPECIAL COLORS
  // ============================================
  
  /// Avatar background
  static const avatarPink = Color(0xFFFFC4D6);
  static const avatarPurple = Color(0xFF8B4789);
  
  /// Navigation bar
  static const navBar = Color(0xFFFFDDB3);
  static const navBarActive = Color(0xFFE8B88A);
  static const navBarIcon = Color(0xFF8B5A3C);
}