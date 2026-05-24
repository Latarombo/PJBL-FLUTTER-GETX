import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/progress_model.dart';
import 'package:santarana/shared/services/progress_service.dart';
import 'package:santarana/shared/services/quiz_service.dart';

class HomeController extends GetxController {
  final QuizService _quizService = QuizService();
  final ProgressService _progressService = ProgressService();

  // ─── STATE ─────────────────────────────────────────────────────────────────
  final isLoadingCategories = false.obs;
  final categories = <CategoryModel>[].obs;

  final isLoadingProgress = false.obs;
  final userProgress = <ProgressModel>[].obs;
  final lastActivity = Rxn<ProgressModel>(); // null jika belum pernah main

  // ─── LIFECYCLE ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchUserProgress();
  }

  // ─── METHODS ───────────────────────────────────────────────────────────────

  /// Fetch semua kategori aktif dari Firestore
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final result = await _quizService.getActiveCategories();
      categories.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat kategori',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Fetch progress user dari Firestore
  /// Dipanggil saat onInit dan saat kembali dari QuizView
  Future<void> fetchUserProgress() async {
    final uid = Get.find<AuthController>().uid;
    if (uid == null) return;

    try {
      isLoadingProgress.value = true;
      final progress = await _progressService.getAllProgress(uid);
      userProgress.value = progress;
      lastActivity.value = progress.isNotEmpty ? progress.first : null;
    } catch (e) {
      // Non-critical: tidak perlu snackbar, cukup log
      // ignore: avoid_print
      print('Warning: gagal memuat progress user: $e');
    } finally {
      isLoadingProgress.value = false;
    }
  }

  /// Navigasi ke QuizView dengan nama kategori sebagai argument
  void goToQuiz(String categoryName) {
    Get.toNamed(Routes.QUIZ, arguments: {'category': categoryName})?.then((_) {
      // Refresh progress saat kembali dari QuizView
      // Ini memastikan card Aktivitas Terakhir langsung update
      fetchUserProgress();
    });
  }
}
