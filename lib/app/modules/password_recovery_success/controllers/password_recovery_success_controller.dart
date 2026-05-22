import 'dart:async';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';

class PasswordRecoverySuccessController extends GetxController {
  final countdown = 5.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        navigateToHome();
      }
    });
  }

  void navigateToHome() {
    _timer?.cancel();
    // GetX: tidak butuh context, tidak butuh mounted check
    Get.offAllNamed(Routes.APP);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
