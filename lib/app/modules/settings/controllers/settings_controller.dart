import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/services/auth_service.dart';

class SettingsController extends GetxController {
  final AuthService _authService = AuthService();
  final AuthController _authController = Get.find<AuthController>();

  // Toggle states — Music, Efek Suara, Getar Ponsel
  final music = true.obs;
  final efekSuara = true.obs;
  final getarPonsel = false.obs;

  void toggleMusic(bool value) => music.value = value;
  void toggleEfekSuara(bool value) => efekSuara.value = value;
  void toggleGetarPonsel(bool value) => getarPonsel.value = value;

  void showComingSoon(String feature) {
    Get.snackbar(
      'Info',
      '$feature akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onBagikan() => showComingSoon('Bagikan');
  void onGantiBahasa() => showComingSoon('Ganti Bahasa');
  void onKontakKami() => showComingSoon('Kontak Kami');
  void onBantuanDukungan() => showComingSoon('Bantuan & Dukungan');
  void onTentangKami() => showComingSoon('Tentang Kami');

  void onLogOut() {
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
