import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  void showFeatureSnackbar(String feature) {
    Get.snackbar('Info', 'Fitur $feature',
        snackPosition: SnackPosition.BOTTOM);
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar Akun?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // GetX: offAllNamed tidak butuh context
              Get.offAllNamed(Routes.SIGN_IN);
            },
            child: const Text('Keluar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
