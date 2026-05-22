import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleObscureConfirmPassword() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void handleRegister() {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!_isValidEmail(emailController.text)) {
      Get.snackbar('Error', 'Format email tidak valid',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (usernameController.text.length < 3) {
      Get.snackbar('Peringatan', 'Username minimal 3 karakter',
          backgroundColor: Colors.orange, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar('Peringatan', 'Password minimal 6 karakter',
          backgroundColor: Colors.orange, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Password tidak sesuai! Cek kembali password Anda.',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.snackbar('Berhasil',
        'Registrasi berhasil! Selamat datang, ${usernameController.text}!',
        backgroundColor: Colors.green, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);

    Get.offAllNamed(Routes.APP);
  }

  void handleGoogleSignIn() => Get.snackbar('Info',
      'Login dengan Google sedang diproses...',
      backgroundColor: Colors.blue, colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void handleFacebookSignIn() => Get.snackbar('Info',
      'Login dengan Facebook sedang diproses...',
      backgroundColor: Colors.blue, colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);

  void goBack() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}