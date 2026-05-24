import 'dart:async';

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
import 'package:santarana/shared/models/question_model.dart';
import 'package:santarana/shared/models/quiz_session_model.dart';
import 'package:santarana/shared/services/progress_service.dart';
import 'package:santarana/shared/services/quiz_result_service.dart';
import 'package:santarana/shared/services/quiz_service.dart';

class QuizController extends GetxController {
  final QuizService _quizService = QuizService();
  final QuizResultService _resultService = QuizResultService();
  final ProgressService _progressService = ProgressService();

  // AuthController diakses via Get.find — sudah di-inject di main.dart
  AuthController get _authController => Get.find<AuthController>();

  // ─── STATE ─────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSaving = false.obs; // loading saat simpan hasil ke Firestore
  final questions = <QuestionModel>[].obs;
  final categoryName = ''.obs;

  final currentQuestionIndex = 0.obs;
  final selectedAnswerIndex = RxnInt();
  final isAnswered = false.obs;
  final correctAnswers = 0.obs;
  final totalPoints = 0.obs;
  final streak = 0.obs;

  // Simpan referensi CategoryModel untuk dipakai saat _saveResults
  CategoryModel? _currentCategory;

  // Catat waktu mulai sesi
  DateTime _startedAt = DateTime.now();

  Timer? _autoAdvanceTimer;

  // ─── GETTERS ───────────────────────────────────────────────────────────────

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex.value] : null;

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

  Future<void> fetchQuestions(String name) async {
    try {
      isLoading.value = true;

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

      // Simpan referensi kategori untuk dipakai di _saveResults
      _currentCategory = category;

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

      // Catat waktu mulai setelah soal berhasil dimuat
      _startedAt = DateTime.now();
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
      // Quiz selesai → simpan hasil dulu, baru tampilkan dialog
      _saveResultsAndShowDialog();
    }
  }

  // ─── SIMPAN HASIL ──────────────────────────────────────────────────────────

  /// Simpan hasil ke Firestore, lalu tampilkan dialog hasil
  Future<void> _saveResultsAndShowDialog() async {
    final uid = _authController.uid;
    final category = _currentCategory;

    // Hitung nilai akhir
    final correct = correctAnswers.value;
    final total = totalQuestions;
    final points = totalPoints.value;
    final percentage = total > 0 ? (correct / total) * 100 : 0.0;
    final grade = QuizSessionModel.calculateGrade(percentage);

    // Tampilkan dialog dulu — simpan di background
    _showResultDialog(
      correct: correct,
      total: total,
      points: points,
      percentage: percentage,
      grade: grade,
    );

    // Simpan ke Firestore di background (tidak perlu await di sini)
    if (uid != null && category != null) {
      _saveResults(
        uid: uid,
        category: category,
        correct: correct,
        total: total,
        percentage: percentage,
        points: points,
        grade: grade,
      );
    }
  }

  Future<void> _saveResults({
    required String uid,
    required CategoryModel category,
    required int correct,
    required int total,
    required double percentage,
    required int points,
    required String grade,
  }) async {
    try {
      isSaving.value = true;

      final session = QuizSessionModel(
        userId: uid,
        categoryId: category.id,
        categoryName: category.name,
        totalQuestions: total,
        correctAnswers: correct,
        wrongAnswers: total - correct,
        pointsEarned: points,
        percentage: percentage,
        grade: grade,
        streak: streak.value,
        isCompleted: true,
        startedAt: _startedAt,
        completedAt: DateTime.now(),
      );

      final progress = ProgressModel(
        categoryId: category.id,
        categoryName: category.name,
        imagePath: category.imagePath,
        bestScore: percentage.round(),
        lastScore: percentage.round(),
        attempts: 1, // akan diakumulasi di ProgressService
        lastProgress: total,
        totalQuestions: total,
        isCompleted: true,
        lastPlayedAt: DateTime.now(),
      );

      // Simpan paralel untuk efisiensi
      await Future.wait([
        _resultService.saveQuizSession(session),
        _resultService.addPointsToUser(uid, points),
        _progressService.saveProgress(uid, category.id, progress),
      ]);

      // Refresh data user di AuthController agar totalPoints di HomeView update
      await _authController.refreshUser();
    } catch (e) {
      // Non-critical untuk UX — dialog sudah tampil, simpan gagal tidak crash
      // ignore: avoid_print
      print('Warning: gagal menyimpan hasil quiz: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ─── DIALOG HASIL ──────────────────────────────────────────────────────────

  void _showResultDialog({
    required int correct,
    required int total,
    required int points,
    required double percentage,
    required String grade,
  }) {
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
                        // Kembali ke APP dan trigger refresh progress di HomeController
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

  // ─── RESET & RESTART ───────────────────────────────────────────────────────

  void resetQuiz() {
    _autoAdvanceTimer?.cancel();
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
            child: const Text(
              'Ya, Ulang',
              style: TextStyle(color: Colors.white),
            ),
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
