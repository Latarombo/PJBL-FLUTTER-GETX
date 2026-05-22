import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:santarana/app/app_shell.dart';
import 'package:santarana/app/modules/home/controllers/home_controller.dart';
import 'package:santarana/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:santarana/app/modules/profile/controllers/profile_controller.dart';
import 'package:santarana/app/modules/settings/controllers/settings_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell controller
    Get.lazyPut<AppShellController>(() => AppShellController());

    // Semua controller halaman dalam shell di-inject sekaligus
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<LeaderboardController>(() => LeaderboardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
