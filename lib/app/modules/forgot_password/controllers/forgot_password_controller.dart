import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  Future<void> validEmailSubmit() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!_isValidEmail(email)) {
      Get.snackbar(
        'Gagal',
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authService.sendPasswordReset(email);
      // Firebase kirim email reset → langsung ke halaman sukses
      Get.offAllNamed(Routes.PASSWORD_RECOVERY_SUCCESS);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
