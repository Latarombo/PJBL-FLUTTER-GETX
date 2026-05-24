import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/modules/home/views/home_view.dart';
import 'package:santarana/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:santarana/app/modules/leaderboard/views/leaderboard_view.dart';
import 'package:santarana/app/modules/profile/views/profile_view.dart';
import 'package:santarana/app/modules/settings/views/settings_view.dart';

class AppShellController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    // Refresh leaderboard stream setiap kali tab leaderboard dibuka
    if (index == 1) {
      Get.find<LeaderboardController>().refresh();
    }
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppShellController>();

    final List<Widget> pages = const [
      HomeView(),
      LeaderboardView(),
      ProfileView(),
      SettingsView(),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: controller.currentIndex.value,
          height: 60,
          items: const [
            Icon(Icons.home_rounded, size: 28, color: Color(0xFF8B5A3C)),
            Icon(Icons.leaderboard, size: 28, color: Color(0xFF8B5A3C)),
            Icon(Icons.person_rounded, size: 28, color: Color(0xFF8B5A3C)),
            Icon(Icons.settings_rounded, size: 28, color: Color(0xFF8B5A3C)),
          ],
          color: const Color(0xFFFFDDB3),
          buttonBackgroundColor: const Color(0xFFE8B88A),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 400),
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
