import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/question_model.dart';
import 'package:santarana/shared/services/quiz_service.dart';
import 'package:santarana/shared/services/category_progress_service.dart';
import 'package:santarana/shared/models/category_progress_model.dart';

class KategoriKuisController extends GetxController {
  final QuizService _quizService = QuizService();
  final CategoryProgressService _progressService = CategoryProgressService();
  AuthController get _auth => Get.find<AuthController>();

  // ── State ──────────────────────────────────────────────────────────────────
  late String categoryName;
  CategoryModel? _categoryModel;

  final isLoading = true.obs;
  final cards = <CardWithStatus>[].obs;

  // Semua soal per level (cached setelah fetch)
  final _allQuestions = <QuestionModel>[];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    categoryName = args?['category'] as String? ?? 'Kategori';
    _load();
  }

  // ── Load: fetch category + questions + progress ────────────────────────────
  Future<void> _load() async {
    try {
      isLoading.value = true;

      // 1. Ambil CategoryModel dari Firestore
      _categoryModel = await _quizService.getCategoryByName(categoryName);
      if (_categoryModel == null) {
        _showError('Kategori tidak ditemukan');
        return;
      }

      // 2. Fetch semua soal aktif untuk kategori ini
      final questions = await _quizService.getQuestionsByCategoryId(
        _categoryModel!.id,
      );
      _allQuestions
        ..clear()
        ..addAll(questions);

      // 3. Fetch progress user dari Firestore
      await _refreshProgress();
    } catch (e) {
      _showError('Gagal memuat data');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Refresh progress (dipanggil setelah quiz selesai) ────────────────────
  Future<void> _refreshProgress() async {
    final uid = _auth.uid;
    if (uid == null || _categoryModel == null) return;

    final progressMap = await _progressService.getAllCardProgress(
      uid: uid,
      categoryId: _categoryModel!.id,
    );

    cards.value = _progressService.buildCardsWithStatus(progressMap);
  }

  // ── Handler tap card ───────────────────────────────────────────────────────
  void onCardTap(CardWithStatus card) {
    switch (card.status) {
      case CardStatus.locked:
        Get.snackbar(
          '🔒 Terkunci',
          'Selesaikan card ${card.cardNumber - 1} dengan 100% benar terlebih dahulu!',
          backgroundColor: const Color(0xFF8B3A3A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case CardStatus.completed:
        Get.snackbar(
          '✅ Sudah Selesai',
          'Card ${_padNumber(card.cardNumber)} sudah kamu selesaikan! Coba card berikutnya.',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case CardStatus.available:
        _startQuiz(card);
        break;
    }
  }

  // ── Mulai quiz untuk card ini ─────────────────────────────────────────────
  void _startQuiz(CardWithStatus card) {
    if (_categoryModel == null) return;

    // Filter soal berdasarkan level card
    final levelQuestions = _progressService.filterByLevel(
      _allQuestions,
      card.level,
    );

    // Ambil sejumlah soal sesuai totalSoal card, shuffle
    final soalUntukCard = levelQuestions.take(card.totalSoal).toList();

    if (soalUntukCard.isEmpty) {
      Get.snackbar(
        'Info',
        'Belum ada soal level ${card.level} untuk kategori ini',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigasi ke QuizView dengan argument lengkap
    Get.toNamed(
      Routes.QUIZ,
      arguments: {
        'category': categoryName,
        'categoryId': _categoryModel!.id,
        'cardNumber': card.cardNumber,
        'level': card.level,
        'totalSoal': card.totalSoal,
        'questions': soalUntukCard,
        'previouslyCorrectIds': card.previouslyCorrectIds,
      },
    )?.then((_) {
      // Refresh setelah kembali dari quiz
      _refreshProgress();
    });
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  String _padNumber(int n) => n.toString().padLeft(2, '0');

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goBack() => Get.back();
}
