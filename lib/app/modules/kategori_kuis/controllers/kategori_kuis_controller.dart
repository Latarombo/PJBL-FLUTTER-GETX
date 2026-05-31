import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/category_progress_model.dart';
import 'package:santarana/shared/services/quiz_service.dart';
import 'package:santarana/shared/services/category_progress_service.dart';

class KategoriKuisController extends GetxController {
  final QuizService _quizService = QuizService();
  final CategoryProgressService _progressService = CategoryProgressService();
  AuthController get _auth => Get.find<AuthController>();

  // ── State ──────────────────────────────────────────────────────────────────
  late String categoryName;
  CategoryModel? _categoryModel;

  final isLoading = true.obs;
  final cards = <CardWithStatus>[].obs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    categoryName = args?['category'] as String? ?? 'Kategori';
    _load();
  }

  // ── Load: fetch category + progress ───────────────────────────────────────
  //
  // Soal TIDAK di-fetch semua di sini.
  // Setiap card fetch soalnya sendiri saat di-tap (_startQuiz).
  Future<void> _load() async {
    try {
      isLoading.value = true;

      // 1. Ambil CategoryModel dari Firestore
      _categoryModel = await _quizService.getCategoryByName(categoryName);
      if (_categoryModel == null) {
        _showError('Kategori tidak ditemukan');
        return;
      }

      // 2. Fetch progress user dari Firestore
      await _refreshProgress();
    } catch (e) {
      _showError('Gagal memuat data');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Refresh progress ──────────────────────────────────────────────────────
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

      case CardStatus.replay:
        _showReplayConfirmation(card);
        break;

      case CardStatus.available:
        _startQuiz(card);
        break;

      case CardStatus.completed:
        _startQuiz(card);
        break;
    }
  }

  // ── Konfirmasi sebelum replay ──────────────────────────────────────────────
  void _showReplayConfirmation(CardWithStatus card) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.replay_rounded,
              color: Color(0xFF5A8B7E),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Ulangi Card ${_padNumber(card.cardNumber)}?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF270F0F),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kamu sudah menyelesaikan card ini! Kamu tetap bisa mengulang untuk latihan.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFB347).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFE65100), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Semua soal sudah pernah dijawab benar, poin yang didapat = 0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE65100),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _startQuiz(card);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A8B7E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Ulangi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Mulai quiz: fetch soal by cardNumber dulu ─────────────────────────────
  Future<void> _startQuiz(CardWithStatus card) async {
    if (_categoryModel == null) return;

    // Tampilkan loading ringan di atas card
    isLoading.value = true;

    try {
      // Fetch soal khusus untuk card ini dari Firestore
      final result = await _quizService.getQuestionsByCard(
        categoryId: _categoryModel!.id,
        cardNumber: card.cardNumber,
        requiredCount: card.totalSoal,
      );

      final questions = result['questions'] as List;
      final isEnough = result['isEnough'] as bool;
      final found = result['found'] as int;

      // Validasi: soal harus cukup
      if (!isEnough) {
        Get.snackbar(
          '⚠️ Soal Belum Lengkap',
          'Card ${_padNumber(card.cardNumber)} membutuhkan ${card.totalSoal} soal, '
              'tapi baru tersedia $found soal. Hubungi admin.',
          backgroundColor: const Color(0xFFE65100),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Navigasi ke QuizView dengan soal yang sudah di-fetch
      Get.toNamed(
        Routes.QUIZ,
        arguments: {
          'category': categoryName,
          'categoryId': _categoryModel!.id,
          'cardNumber': card.cardNumber,
          'level': card.level,
          'totalSoal': card.totalSoal,
          'questions': questions,
          'previouslyCorrectIds': card.previouslyCorrectIds,
        },
      )?.then((_) {
        _refreshProgress();
      });
    } catch (e) {
      _showError('Gagal memuat soal, coba lagi');
    } finally {
      isLoading.value = false;
    }
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
