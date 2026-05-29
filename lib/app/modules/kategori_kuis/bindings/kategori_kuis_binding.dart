import 'package:get/get.dart';

import '../controllers/kategori_kuis_controller.dart';

class KategoriKuisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KategoriKuisController>(
      () => KategoriKuisController(),
    );
  }
}
