import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleObscureConfirmPassword() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  Future<void> handleRegister() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty || confirm.isEmpty) {
      Get.snackbar(
        'Gagal', 'Semua field harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!_isValidEmail(email)) {
      Get.snackbar(
        'Gagal', 'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (username.length < 3) {
      Get.snackbar(
        'Peringatan', 'Username minimal 3 karakter',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password.length < 6) {
      Get.snackbar(
        'Peringatan', 'Password minimal 6 karakter',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password != confirm) {
      Get.snackbar(
        'Gagal', 'Password tidak sesuai! Cek kembali password Anda.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = await _authService.register(email, username, password);
      Get.find<AuthController>().setUser(user);
      Get.offAllNamed(Routes.APP);
    } catch (e) {
      Get.snackbar(
        'Registrasi Gagal',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleGoogleSignIn() => Get.snackbar(
        'Info', 'Login dengan Google sedang diproses...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

  void handleFacebookSignIn() => Get.snackbar(
        'Info', 'Login dengan Facebook sedang diproses...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

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