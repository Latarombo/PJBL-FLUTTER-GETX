import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';

class EmailVerificationController extends GetxController {
  // Ambil email dari arguments GetX (ganti settings.arguments)
  String get email => Get.arguments?['email'] ?? 'user@example.com';

  String otpCode = '';

  void onOtpCompleted(String otp) {
    otpCode = otp;
  }

  void onConfirm() {
    if (otpCode.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Mohon lengkapi kode OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (otpCode.length != 4) {
      Get.snackbar(
        'Error',
        'Kode OTP tidak valid. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(Routes.PASSWORD_RECOVERY_SUCCESS);
  }

  void goBack() => Get.back();
}
