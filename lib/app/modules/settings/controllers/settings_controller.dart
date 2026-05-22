import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SettingsController extends GetxController {
  // .obs menggantikan bool biasa + setState
  final volumeSuara = true.obs;
  final deringPonsel = true.obs;
  final notifikasi = true.obs;

  void toggleVolumeSuara(bool value) => volumeSuara.value = value;
  void toggleDeringPonsel(bool value) => deringPonsel.value = value;
  void toggleNotifikasi(bool value) => notifikasi.value = value;

  void showComingSoon(String feature) {
    Get.snackbar(
      'Info',
      '$feature akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
