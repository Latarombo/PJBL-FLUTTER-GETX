import 'package:get/get.dart';
import 'package:santarana/app/modules/daily_mission/controller/daily_mission_controller.dart';

class DailyMissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyMissionController>(() => DailyMissionController());
  }
}
