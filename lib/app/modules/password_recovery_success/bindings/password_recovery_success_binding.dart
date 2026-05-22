import 'package:get/get.dart';

import '../controllers/password_recovery_success_controller.dart';

class PasswordRecoverySuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordRecoverySuccessController>(
      () => PasswordRecoverySuccessController(),
    );
  }
}
