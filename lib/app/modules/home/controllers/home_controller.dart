import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';

class HomeController extends GetxController {
  void goToQuiz(String category) {
    Get.toNamed(Routes.QUIZ, arguments: {'category': category});
  }
}
