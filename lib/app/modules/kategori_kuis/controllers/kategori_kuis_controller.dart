import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';

// ── Model misi per card ───────────────────────────────────────────────────────
class KuisMission {
  final int number;
  final String difficulty;
  final KuisMissionStatus status;

  const KuisMission({
    required this.number,
    required this.difficulty,
    required this.status,
  });
}

enum KuisMissionStatus { completed, inProgress, locked }

class KategoriKuisController extends GetxController {
  // ── Nama kategori dari argument ─────────────────────────────────────────
  late final String categoryName;

  // ── Dummy data misi (hardcoded, 10 misi) ───────────────────────────────
  // TODO: ganti dengan data dinamis dari Firestore jika sudah siap
  final missions = <KuisMission>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Ambil nama kategori dari argument GetX
    final args = Get.arguments as Map<String, dynamic>?;
    categoryName = args?['category'] as String? ?? 'Kategori';

    // Inisialisasi dummy data misi
    _initDummyMissions();
  }

  void _initDummyMissions() {
    missions.value = [
      const KuisMission(number: 1, difficulty: 'Mudah', status: KuisMissionStatus.completed),
      const KuisMission(number: 2, difficulty: 'Mudah', status: KuisMissionStatus.inProgress),
      const KuisMission(number: 3, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 4, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 5, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 6, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 7, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 8, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 9, difficulty: 'Mudah', status: KuisMissionStatus.locked),
      const KuisMission(number: 10, difficulty: 'Mudah', status: KuisMissionStatus.locked),
    ];
  }

  // ── Handler tap card misi ───────────────────────────────────────────────
  void onMissionTap(KuisMission mission) {
    switch (mission.status) {
      case KuisMissionStatus.completed:
        Get.snackbar(
          '✅ Misi ${_padNumber(mission.number)} Selesai',
          'Kamu sudah menyelesaikan misi ini. Bagus sekali!',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case KuisMissionStatus.inProgress:
        // Navigasi ke QuizView dengan kategori ini
        Get.toNamed(
          Routes.QUIZ,
          arguments: {'category': categoryName},
        );
        break;

      case KuisMissionStatus.locked:
        Get.snackbar(
          '🔒 Misi Terkunci',
          'Selesaikan misi sebelumnya terlebih dahulu!',
          backgroundColor: const Color(0xFF8B3A3A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;
    }
  }

  // ── Helper ──────────────────────────────────────────────────────────────
  String _padNumber(int n) => n.toString().padLeft(2, '0');

  void goBack() => Get.back();
}