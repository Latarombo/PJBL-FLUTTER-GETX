// lib/app/app_shell.dart
//
// FIX: AppShellController.onInit() memanggil startBgm() secara async
// menggunakan Future.microtask agar tidak memblokir build frame pertama.
// Sebelumnya pemanggilan langsung di onInit menyebabkan Choreographer
// "Skipped 131 frames" karena AudioPlayer initialization terjadi di main thread
// saat pertama kali widget di-render.

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/modules/home/views/home_view.dart';
import 'package:santarana/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:santarana/app/modules/leaderboard/views/leaderboard_view.dart';
import 'package:santarana/app/modules/profile/views/profile_view.dart';
import 'package:santarana/app/modules/settings/views/settings_view.dart';
import 'package:santarana/shared/services/audio_service.dart';

class AppShellController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // FIX: Gunakan Future.microtask agar startBgm tidak dieksekusi
    // synchronous di dalam build pipeline frame pertama.
    // Ini mencegah "Skipped N frames" yang disebabkan AudioPlayer
    // init (I/O + AudioSession config) di main thread saat mount.
    Future.microtask(() => AudioService.instance.startBgm());
  }

  @override
  void onClose() {
    AudioService.instance.stopBgm();
    super.onClose();
  }

  void changePage(int index) {
    currentIndex.value = index;

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
