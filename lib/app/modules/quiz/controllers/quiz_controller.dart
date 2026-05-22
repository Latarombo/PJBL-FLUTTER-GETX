import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/data/quiz_data.dart';
import 'package:santarana/shared/data/quiz_model.dart';

class QuizController extends GetxController {
  // Ambil category dari Get.arguments (ganti widget.category)
  late QuizSession quizSession;

  // Semua state menjadi .obs
  final currentQuestionIndex = 0.obs;
  final selectedAnswerIndex = RxnInt(); // nullable int
  final isAnswered = false.obs;
  final correctAnswers = 0.obs;
  final totalPoints = 0.obs;
  final streak = 0.obs;

  Timer? _autoAdvanceTimer;

  // Getter untuk soal saat ini
  QuizQuestion get currentQuestion =>
      quizSession.questions[currentQuestionIndex.value];

  @override
  void onInit() {
    super.onInit();
    // Ambil argument dari GetX (ganti settings.arguments)
    final args = Get.arguments as Map<String, dynamic>?;
    final category = args?['category'] as String? ?? 'Tarian Tradisional';
    quizSession = QuizData.getQuizByCategory(category);
  }

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

    if (selectedAnswerIndex.value == currentQuestion.correctAnswerIndex) {
      correctAnswers.value++;
      streak.value++;

      int basePoint = 10;
      int bonus = streak.value >= 3 ? 5 : 0;
      totalPoints.value += basePoint + bonus;
    } else {
      streak.value = 0;
    }

    _autoAdvanceTimer = Timer(const Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() {
    if (currentQuestionIndex.value < quizSession.questions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswerIndex.value = null;
      isAnswered.value = false;
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final result = QuizResult(
      correctAnswers: correctAnswers.value,
      totalQuestions: quizSession.totalQuestions,
      pointsEarned: totalPoints.value,
      completedAt: DateTime.now(),
    );

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
                  color: result.percentage >= 70
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.percentage >= 70 ? Icons.emoji_events : Icons.refresh,
                  size: 40,
                  color: result.percentage >= 70 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                result.grade,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Skor: ${result.correctAnswers}/${result.totalQuestions}',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                'Persentase: ${result.percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                      '+${result.pointsEarned} Poin',
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
                        Get.back(); // tutup dialog
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
    currentQuestionIndex.value = 0;
    selectedAnswerIndex.value = null;
    isAnswered.value = false;
    correctAnswers.value = 0;
    totalPoints.value = 0;
    streak.value = 0;
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
            child: const Text(
              'Ya, Ulang',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _autoAdvanceTimer?.cancel();
    super.onClose();
  }
}
