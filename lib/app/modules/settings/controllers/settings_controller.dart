import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SettingsController extends GetxController {
  // Toggle states — sesuai foto: Music, Efek Suara, Getar Ponsel
  final music = true.obs;
  final efekSuara = true.obs;
  final getarPonsel = false.obs;

  void toggleMusic(bool value) => music.value = value;
  void toggleEfekSuara(bool value) => efekSuara.value = value;
  void toggleGetarPonsel(bool value) => getarPonsel.value = value;

  void showComingSoon(String feature) {
    Get.snackbar(
      'Info',
      '$feature akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onBagikan() => showComingSoon('Bagikan');
  void onGantiBahasa() => showComingSoon('Ganti Bahasa');
  void onKontakKami() => showComingSoon('Kontak Kami');
  void onBantuanDukungan() => showComingSoon('Bantuan & Dukungan');
  void onTentangKami() => showComingSoon('Tentang Kami');

  void onLogOut() {
    // Navigasi ke halaman logout / trigger logout dari sini
    // Bisa diganti dengan logika logout sesuai kebutuhan
    showComingSoon('Log Out');
  }
}