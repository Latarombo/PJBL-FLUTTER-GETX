import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/services/quiz_service.dart';

class HomeController extends GetxController {
  final QuizService _quizService = QuizService();

  // ─── STATE ─────────────────────────────────────────────────────────────────
  final isLoadingCategories = false.obs;
  final categories = <CategoryModel>[].obs;

  // ─── LIFECYCLE ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
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

  /// Navigasi ke QuizView dengan nama kategori sebagai argument
  /// Nama kategori dikirim → QuizController akan fetch categoryId dari Firestore
  void goToQuiz(String categoryName) {
    Get.toNamed(Routes.QUIZ, arguments: {'category': categoryName});
  }
}