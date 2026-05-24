import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/models/question_model.dart';
import 'package:santarana/shared/services/quiz_service.dart';

class QuizController extends GetxController {
  final QuizService _quizService = QuizService();

  // ─── STATE ─────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final questions = <QuestionModel>[].obs;
  final categoryName = ''.obs;        // nama kategori yang sedang dimainkan

  final currentQuestionIndex = 0.obs;
  final selectedAnswerIndex = RxnInt();
  final isAnswered = false.obs;
  final correctAnswers = 0.obs;
  final totalPoints = 0.obs;
  final streak = 0.obs;

  Timer? _autoAdvanceTimer;

  // ─── GETTERS ───────────────────────────────────────────────────────────────

  /// Soal yang sedang ditampilkan
  QuestionModel? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex.value] : null;

  /// Total soal dalam sesi ini
  int get totalQuestions => questions.length;

  // ─── LIFECYCLE ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final category = args?['category'] as String? ?? '';
    categoryName.value = category;
    fetchQuestions(category);
  }

  // ─── FETCH ─────────────────────────────────────────────────────────────────

  /// Fetch soal dari Firestore berdasarkan nama kategori
  /// Flow: nama kategori → cari categoryId → fetch questions by categoryId
  Future<void> fetchQuestions(String name) async {
    try {
      isLoading.value = true;

      // Step 1: Cari kategori berdasarkan nama untuk dapat categoryId
      final category = await _quizService.getCategoryByName(name);
      if (category == null) {
        Get.snackbar(
          'Error',
          'Kategori "$name" tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Step 2: Fetch soal menggunakan categoryId (document ID)
      final result = await _quizService.getQuestionsByCategoryId(category.id);
      if (result.isEmpty) {
        Get.snackbar(
          'Info',
          'Belum ada soal untuk kategori ini',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      questions.value = result;
      _resetState();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat soal',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── QUIZ LOGIC ────────────────────────────────────────────────────────────

  void selectAnswer(int index) {
    if (!isAnswered.value) {
      selectedAnswerIndex.value = index;
    }
  }

  void handleNext() {
    if (selectedAnswerIndex.value == null) {
      Get.snackbar(
        'Peringatan',
        'Silakan pilih jawaban terlebih dahulu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isAnswered.value = true;

    final correct = currentQuestion?.correctIndex ?? -1;
    if (selectedAnswerIndex.value == correct) {
      correctAnswers.value++;
      streak.value++;
      final bonus = streak.value >= 3 ? 5 : 0;
      totalPoints.value += 10 + bonus;
    } else {
      streak.value = 0;
    }

    _autoAdvanceTimer = Timer(const Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswerIndex.value = null;
      isAnswered.value = false;
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final correct = correctAnswers.value;
    final total = totalQuestions;
    final points = totalPoints.value;
    final percentage = total > 0 ? (correct / total) * 100 : 0.0;

    String grade;
    if (percentage >= 90) {
      grade = 'Sempurna!';
    } else if (percentage >= 80) {
      grade = 'Sangat Baik!';
    } else if (percentage >= 70) {
      grade = 'Baik';
    } else if (percentage >= 60) {
      grade = 'Cukup';
    } else {
      grade = 'Perlu Belajar Lagi';
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: percentage >= 70
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  percentage >= 70 ? Icons.emoji_events : Icons.refresh,
                  size: 40,
                  color: percentage >= 70 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                grade,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Skor: $correct/$total',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                'Persentase: ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB347).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFB347), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+$points Poin',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        resetQuiz();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Ulang Quiz'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offNamedUntil(Routes.APP, (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2332),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void resetQuiz() {
    _autoAdvanceTimer?.cancel();
    // Re-fetch untuk shuffle ulang soal
    fetchQuestions(categoryName.value);
  }

  void showRestartDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ulang Quiz?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Semua progress akan hilang. Apakah Anda yakin ingin mengulang quiz dari awal?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              resetQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A2332),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Ulang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resetState() {
    currentQuestionIndex.value = 0;
    selectedAnswerIndex.value = null;
    isAnswered.value = false;
    correctAnswers.value = 0;
    totalPoints.value = 0;
    streak.value = 0;
  }

  @override
  void onClose() {
    _autoAdvanceTimer?.cancel();
    super.onClose();
  }
}