import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final AuthController _authController = Get.find<AuthController>();

  // Navigasi ke halaman Edit Account (buat route baru nanti)
  void goToEditAccount() {
    Get.toNamed(Routes.EDIT_PROFILE);
  }

  void showFeatureSnackbar(String feature) {
    Get.snackbar(
      'Info',
      'Fitur $feature akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar akun?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _doLogout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout() async {
    try {
      await _authService.signOut();
      _authController.clearUser();
      Get.offAllNamed(Routes.SIGN_IN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
