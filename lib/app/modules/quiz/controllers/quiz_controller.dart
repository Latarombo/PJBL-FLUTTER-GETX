import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/category_progress_model.dart';
import 'package:santarana/shared/models/progress_model.dart';
import 'package:santarana/shared/models/question_model.dart';
import 'package:santarana/shared/models/quiz_session_model.dart';
import 'package:santarana/shared/services/category_progress_service.dart';
import 'package:santarana/shared/services/leaderboard_service.dart';
import 'package:santarana/shared/services/progress_service.dart';
import 'package:santarana/shared/services/quiz_result_service.dart';
import 'package:santarana/shared/services/quiz_service.dart';
import 'package:santarana/shared/theme/app_colors.dart';

class QuizController extends GetxController {
  final QuizService _quizService = QuizService();
  final QuizResultService _resultService = QuizResultService();
  final ProgressService _progressService = ProgressService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final CategoryProgressService _cardProgressService =
      CategoryProgressService();

  AuthController get _authController => Get.find<AuthController>();

  // ─── STATE ─────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSaving = false.obs;
  final questions = <QuestionModel>[].obs;
  final categoryName = ''.obs;

  final currentQuestionIndex = 0.obs;
  final selectedAnswerIndex = RxnInt();
  final isAnswered = false.obs;
  final correctAnswers = 0.obs;
  final totalPoints = 0.obs;
  final streak = 0.obs;

  // ─── Card-based quiz state ──────────────────────────────────────────────────
  /// Card number (1-10) jika quiz dari KategoriKuisView, null jika dari HomeView
  int? _cardNumber;
  String? _categoryId;
  int? _totalSoalInCard;

  /// Soal yang sudah benar di sesi sebelumnya (untuk card-based)
  List<String> _previouslyCorrectIds = [];

  /// Map: questionId → benar/salah untuk sesi ini
  final Map<String, bool> _answeredCorrectly = {};

  /// Poin yang benar-benar akan dikreditkan (hanya soal baru yang benar)
  int _newPointsEarned = 0;

  CategoryModel? _currentCategory;
  DateTime _startedAt = DateTime.now();
  Timer? _autoAdvanceTimer;

  // ─── GETTERS ───────────────────────────────────────────────────────────────
  QuestionModel? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex.value] : null;

  int get totalQuestions => questions.length;

  /// Apakah ini card-based quiz (dari KategoriKuisView)
  bool get isCardBased => _cardNumber != null;

  // ─── LIFECYCLE ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _initFromArgs(args);
  }

  void _initFromArgs(Map<String, dynamic>? args) {
    final category = args?['category'] as String? ?? '';
    categoryName.value = category;

    // Card-based quiz: questions sudah dikirim dari KategoriKuisController
    final preloadedQuestions = args?['questions'] as List<QuestionModel>?;
    _cardNumber = args?['cardNumber'] as int?;
    _categoryId = args?['categoryId'] as String?;
    _totalSoalInCard = args?['totalSoal'] as int?;
    _previouslyCorrectIds = List<String>.from(
      args?['previouslyCorrectIds'] ?? [],
    );

    if (preloadedQuestions != null && preloadedQuestions.isNotEmpty) {
      // Mode: soal sudah diload oleh KategoriKuisController
      questions.value = preloadedQuestions;
      _resetState();
      _startedAt = DateTime.now();
      // Fetch category model di background (untuk save hasil)
      _fetchCategoryModel(category);
    } else {
      // Mode: fetch soal sendiri (dari HomeView atau route langsung)
      fetchQuestions(category);
    }
  }

  // ─── FETCH (mode legacy dari HomeView) ────────────────────────────────────
  Future<void> fetchQuestions(String name) async {
    try {
      isLoading.value = true;
      final category = await _quizService.getCategoryByName(name);
      if (category == null) {
        _showSnackbar(
          'Error',
          'Kategori "$name" tidak ditemukan',
          isError: true,
        );
        return;
      }
      _currentCategory = category;
      _categoryId ??= category.id;

      final result = await _quizService.getQuestionsByCategoryId(category.id);
      if (result.isEmpty) {
        _showSnackbar(
          'Info',
          'Belum ada soal untuk kategori ini',
          isError: false,
        );
        return;
      }

      questions.value = result;
      _resetState();
      _startedAt = DateTime.now();
    } catch (e) {
      _showSnackbar('Error', 'Gagal memuat soal', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCategoryModel(String name) async {
    try {
      _currentCategory = await _quizService.getCategoryByName(name);
    } catch (_) {
      // non-critical
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
      _showSnackbar(
        'Peringatan',
        'Silakan pilih jawaban terlebih dahulu',
        isError: false,
      );
      return;
    }

    isAnswered.value = true;

    final correct = currentQuestion?.correctIndex ?? -1;
    final isCorrect = selectedAnswerIndex.value == correct;
    final questionId = currentQuestion?.id ?? '';

    // Catat hasil soal ini
    _answeredCorrectly[questionId] = isCorrect;

    if (isCorrect) {
      correctAnswers.value++;
      streak.value++;

      // Hitung poin hanya jika soal ini belum pernah benar sebelumnya
      if (!_previouslyCorrectIds.contains(questionId)) {
        final bonus = streak.value >= 3 ? 5 : 0;
        final pointsThisQuestion = 10 + bonus;
        totalPoints.value += pointsThisQuestion;
        _newPointsEarned += pointsThisQuestion;
      }
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
      _saveResultsAndShowDialog();
    }
  }

  // ─── SIMPAN HASIL ──────────────────────────────────────────────────────────
  Future<void> _saveResultsAndShowDialog() async {
    final uid = _authController.uid;
    final category = _currentCategory;

    final correct = correctAnswers.value;
    final total = totalQuestions;
    final percentage = total > 0 ? (correct / total) * 100 : 0.0;
    final grade = QuizSessionModel.calculateGrade(percentage);

    // Tampilkan dialog terlebih dahulu
    _showResultDialog(
      correct: correct,
      total: total,
      points: _newPointsEarned,
      percentage: percentage,
      grade: grade,
    );

    // Simpan di background
    if (uid != null) {
      _saveResults(
        uid: uid,
        category: category,
        correct: correct,
        total: total,
        percentage: percentage,
        grade: grade,
      );
    }
  }

  Future<void> _saveResults({
    required String uid,
    required CategoryModel? category,
    required int correct,
    required int total,
    required double percentage,
    required String grade,
  }) async {
    try {
      isSaving.value = true;

      final futures = <Future>[];

      // 1. Simpan progress card (jika card-based)
      if (isCardBased && _categoryId != null && _cardNumber != null) {
        futures.add(
          _cardProgressService.saveCardProgress(
            uid: uid,
            categoryId: _categoryId!,
            cardNumber: _cardNumber!,
            totalSoalInCard: _totalSoalInCard ?? total,
            answeredCorrectly: _answeredCorrectly,
            existingProgress: null, // service akan fetch sendiri jika perlu
          ),
        );
      }

      // 2. Tambah poin ke user (hanya poin baru)
      if (_newPointsEarned > 0) {
        futures.add(_resultService.addPointsToUser(uid, _newPointsEarned));

        // 3. Update leaderboard
        futures.add(
          _leaderboardService.updateLeaderboardEntry(
            uid,
            _authController.username,
            _authController.totalPoints + _newPointsEarned,
            avatarUrl: _authController.avatarUrl,
          ),
        );
      }

      // 4. Simpan sesi quiz (untuk riwayat)
      if (category != null) {
        final session = QuizSessionModel(
          userId: uid,
          categoryId: category.id,
          categoryName: category.name,
          totalQuestions: total,
          correctAnswers: correct,
          wrongAnswers: total - correct,
          pointsEarned: _newPointsEarned,
          percentage: percentage,
          grade: grade,
          streak: streak.value,
          isCompleted: true,
          startedAt: _startedAt,
          completedAt: DateTime.now(),
        );
        futures.add(_resultService.saveQuizSession(session));

        // 5. Simpan progress kategori (untuk "Aktivitas Terakhir" di Home)
        final progressModel = ProgressModel(
          categoryId: category.id,
          categoryName: category.name,
          imagePath: category.imagePath,
          bestScore: percentage.round(),
          lastScore: percentage.round(),
          attempts: 1,
          lastProgress: total,
          totalQuestions: total,
          isCompleted: percentage >= 100,
          lastPlayedAt: DateTime.now(),
        );
        futures.add(
          _progressService.saveProgress(uid, category.id, progressModel),
        );
      }

      await Future.wait(futures);
      await _authController.refreshUser();
    } catch (e) {
      // Non-critical
      debugPrint('Warning: gagal menyimpan hasil quiz: $e');
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
    // Apakah semua soal benar (card completed)?
    final isPerfect = percentage >= 100;
    // Apakah ada poin baru?
    final hasNewPoints = points > 0;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon hasil
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isPerfect
                      ? Colors.green.withValues(alpha: 0.1)
                      : percentage >= 70
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPerfect
                      ? Icons.emoji_events_rounded
                      : percentage >= 70
                      ? Icons.thumb_up_rounded
                      : Icons.refresh_rounded,
                  size: 40,
                  color: isPerfect
                      ? const Color(0xFFFFD700)
                      : percentage >= 70
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 16),

              // Grade
              Text(
                grade,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF270F0F),
                ),
              ),
              const SizedBox(height: 8),

              // Skor
              Text(
                'Jawaban Benar: $correct/$total',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF270F0F),
                ),
              ),
              const SizedBox(height: 12),

              // Info poin
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: hasNewPoints
                      ? const Color(0xFFFFB347).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: hasNewPoints
                          ? const Color(0xFFFFB347)
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasNewPoints
                          ? '+$points Poin'
                          : 'Sudah pernah benar — +0 Poin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: hasNewPoints
                            ? const Color(0xFF270F0F)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Info card unlock jika perfect
              if (isPerfect && isCardBased) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_open_rounded,
                        color: Color(0xFF2E7D32),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Card ${(_cardNumber ?? 0) + 1} terbuka!',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Tombol
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
                      child: const Text('Ulang'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
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
    _answeredCorrectly.clear();
    _newPointsEarned = 0;

    if (isCardBased) {
      // Reload dari arguments yang sama
      _resetState();
      _startedAt = DateTime.now();
    } else {
      fetchQuestions(categoryName.value);
    }
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
          'Semua progress sesi ini akan hilang. Lanjutkan?',
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
    _answeredCorrectly.clear();
    _newPointsEarned = 0;
  }

  void _showSnackbar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.orange : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    _autoAdvanceTimer?.cancel();
    super.onClose();
  }
}
