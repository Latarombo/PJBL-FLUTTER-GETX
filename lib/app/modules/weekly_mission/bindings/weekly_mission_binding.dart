import 'package:get/get.dart';
import 'package:santarana/app/modules/weekly_mission/controller/weekly_mission_controller.dart';

class DailyMissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeeklyMissionController>(() => WeeklyMissionController());
  }
}
