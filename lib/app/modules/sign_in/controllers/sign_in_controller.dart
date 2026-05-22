import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';

class SignInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // .obs = reaktif (pengganti setState)
  final obscurePassword = true.obs;

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;

  void handleSignIn() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Username dan password tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (usernameController.text.length < 3) {
      Get.snackbar(
        'Peringatan',
        'Username minimal 3 karakter',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Peringatan',
        'Password minimal 6 karakter',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Berhasil',
      'Selamat datang, ${usernameController.text}! Siap menjelajahi keindahan budaya Nusantara?',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    // GetX navigation - hapus semua route sebelumnya
    Get.offAllNamed(Routes.APP);
  }

  void handleGoogleSignIn() {
    Get.snackbar(
      'Info',
      'Login dengan Google sedang diproses...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleFacebookSignIn() {
    Get.snackbar(
      'Info',
      'Login dengan Facebook sedang diproses...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToRegister() => Get.toNamed(Routes.REGISTER);

  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
