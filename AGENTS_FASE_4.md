# ⬜ FASE 4 — Simpan Hasil Quiz & Progress
> Baca `AGENTS.md` (core) terlebih dahulu, lalu baca file ini.
> Status: **STANDBY** — kerjakan setelah Fase 3 selesai & ter-checklist semua.
> Tujuan: Setiap quiz selesai → simpan hasil ke Firestore → update poin user → HomeView reminder card dinamis.

---

## 🎯 TUJUAN FASE INI

- Hasil quiz tersimpan di `quiz_sessions` collection
- Poin user terupdate di `users` collection
- Progress per kategori tersimpan di `user_progress/{uid}/categories/`
- Leaderboard entry terupdate setelah quiz selesai
- HomeView reminder card menampilkan progress nyata
- Stats soal terupdate (`timesAnswered`, `timesWrong`, `wrongRate`)

---

## 📁 FILE BARU YANG HARUS DIBUAT

### 1. `lib/shared/models/quiz_session_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSessionModel {
  final String? id;             // Firestore doc ID (null sebelum disimpan)
  final String userId;
  final String categoryId;
  final String categoryName;
  final int totalQuestions;     // 15
  final int correctAnswers;
  final int wrongAnswers;       // totalQuestions - correctAnswers
  final int pointsEarned;       // poin sesi ini
  final double percentage;      // (correctAnswers / totalQuestions) * 100
  final String grade;           // 'Sempurna!' | 'Sangat Baik!' | 'Baik!' | 'Cukup' | 'Perlu Belajar Lagi'
  final int streak;
  final bool isCompleted;       // true jika sampai soal terakhir
  final DateTime startedAt;
  final DateTime completedAt;

  const QuizSessionModel({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.pointsEarned,
    required this.percentage,
    required this.grade,
    required this.streak,
    required this.isCompleted,
    required this.startedAt,
    required this.completedAt,
  });

  // Helper: hitung grade dari persentase
  static String calculateGrade(double percentage) {
    if (percentage >= 100) return 'Sempurna!';
    if (percentage >= 80) return 'Sangat Baik!';
    if (percentage >= 60) return 'Baik!';
    if (percentage >= 40) return 'Cukup';
    return 'Perlu Belajar Lagi';
  }

  // Helper: hitung poin dari jawaban benar
  static int calculatePoints(int correctAnswers) => correctAnswers * 10;

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers,
    'pointsEarned': pointsEarned,
    'percentage': percentage,
    'grade': grade,
    'streak': streak,
    'isCompleted': isCompleted,
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': Timestamp.fromDate(completedAt),
  };

  factory QuizSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizSessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      pointsEarned: data['pointsEarned'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      grade: data['grade'] ?? '',
      streak: data['streak'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }
}
```

---

### 2. `lib/shared/models/progress_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String categoryId;
  final String categoryName;
  final String imagePath;     // untuk tampilan di HomeView reminder card
  final int bestScore;        // persentase terbaik 0-100
  final int lastScore;        // persentase terakhir
  final int attempts;         // berapa kali main
  final int lastProgress;     // soal terakhir dijawab (misal: 9 dari 15)
  final int totalQuestions;   // 15
  final bool isCompleted;     // pernah selesai sampai soal terakhir
  final DateTime? lastPlayedAt;

  const ProgressModel({
    required this.categoryId,
    required this.categoryName,
    required this.imagePath,
    required this.bestScore,
    required this.lastScore,
    required this.attempts,
    required this.lastProgress,
    required this.totalQuestions,
    required this.isCompleted,
    this.lastPlayedAt,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      categoryId: data['categoryId'] ?? doc.id,
      categoryName: data['categoryName'] ?? '',
      imagePath: data['imagePath'] ?? '',
      bestScore: data['bestScore'] ?? 0,
      lastScore: data['lastScore'] ?? 0,
      attempts: data['attempts'] ?? 0,
      lastProgress: data['lastProgress'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 15,
      isCompleted: data['isCompleted'] ?? false,
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'imagePath': imagePath,
    'bestScore': bestScore,
    'lastScore': lastScore,
    'attempts': attempts,
    'lastProgress': lastProgress,
    'totalQuestions': totalQuestions,
    'isCompleted': isCompleted,
    'lastPlayedAt': lastPlayedAt != null ? Timestamp.fromDate(lastPlayedAt!) : FieldValue.serverTimestamp(),
  };
}
```

---

### 3. `lib/shared/services/quiz_result_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/quiz_session_model.dart';

// ⚠️ Service rules: tidak ada navigasi, tidak ada snackbar
class QuizResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan sesi quiz ke collection 'quiz_sessions'
  Future<void> saveQuizSession(QuizSessionModel session) async {
    try {
      await _firestore.collection('quiz_sessions').add(session.toFirestore());
    } catch (e) {
      throw Exception('Gagal menyimpan hasil quiz: $e');
    }
  }

  // Update totalPoints user (FieldValue.increment agar atomic)
  Future<void> addPointsToUser(String uid, int pointsEarned) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'totalPoints': FieldValue.increment(pointsEarned),
        'quizCompleted': FieldValue.increment(1),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal update poin user: $e');
    }
  }

  // Update stats soal setelah setiap jawaban
  Future<void> updateQuestionStats(String questionId, bool isWrong) async {
    try {
      final ref = _firestore.collection('questions').doc(questionId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        final stats = snapshot.data()?['stats'] as Map<String, dynamic>? ?? {};
        final timesAnswered = (stats['timesAnswered'] ?? 0) + 1;
        final timesWrong = (stats['timesWrong'] ?? 0) + (isWrong ? 1 : 0);
        final wrongRate = timesAnswered > 0 ? (timesWrong / timesAnswered) * 100 : 0.0;
        transaction.update(ref, {
          'stats.timesAnswered': timesAnswered,
          'stats.timesWrong': timesWrong,
          'stats.wrongRate': wrongRate,
        });
      });
    } catch (e) {
      // Stats update non-critical — log saja, jangan throw
      // ignore: avoid_print
      print('Warning: gagal update stats soal $questionId: $e');
    }
  }
}
```

---

### 4. `lib/shared/services/progress_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/progress_model.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Path: user_progress/{uid}/categories/{categoryId}
  Future<void> saveProgress(String uid, String categoryId, ProgressModel progress) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc(uid)
          .collection('categories')
          .doc(categoryId)
          .set(progress.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal menyimpan progress: $e');
    }
  }

  // Ambil semua progress user (untuk HomeView reminder cards)
  Future<List<ProgressModel>> getAllProgress(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(uid)
          .collection('categories')
          .orderBy('lastPlayedAt', descending: true)
          .get();
      return snapshot.docs.map(ProgressModel.fromFirestore).toList();
    } catch (e) {
      throw Exception('Gagal mengambil progress: $e');
    }
  }

  // Ambil progress satu kategori
  Future<ProgressModel?> getProgress(String uid, String categoryId) async {
    try {
      final doc = await _firestore
          .collection('user_progress')
          .doc(uid)
          .collection('categories')
          .doc(categoryId)
          .get();
      if (!doc.exists) return null;
      return ProgressModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil progress kategori: $e');
    }
  }

  // Ambil aktivitas terakhir (lastPlayedAt terbaru) — untuk HomeView reminder
  Future<ProgressModel?> getLastActivity(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(uid)
          .collection('categories')
          .orderBy('lastPlayedAt', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return ProgressModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }
}
```

---

## 📝 FILE YANG HARUS DIUPDATE

### `quiz_controller.dart` — Simpan Hasil Setelah Quiz Selesai

```dart
// Tambahkan dependencies:
final AuthController _authController = Get.find<AuthController>();
final QuizResultService _resultService = QuizResultService();
final ProgressService _progressService = ProgressService();

// Catat waktu mulai di onInit():
final DateTime _startedAt = DateTime.now();

// Di _showResultDialog() atau fungsi yang dipanggil saat quiz selesai,
// SEBELUM dialog ditampilkan, panggil _saveResults():
Future<void> _saveResults() async {
  final uid = _authController.uid;
  if (uid == null) return;

  final correctAnswers = /* hitung dari state */;
  final totalQuestions = questions.length;
  final percentage = (correctAnswers / totalQuestions) * 100;
  final pointsEarned = QuizSessionModel.calculatePoints(correctAnswers);

  final session = QuizSessionModel(
    userId: uid,
    categoryId: currentCategory!.id,
    categoryName: currentCategory!.name,
    totalQuestions: totalQuestions,
    correctAnswers: correctAnswers,
    wrongAnswers: totalQuestions - correctAnswers,
    pointsEarned: pointsEarned,
    percentage: percentage,
    grade: QuizSessionModel.calculateGrade(percentage),
    streak: _authController.streak,
    isCompleted: true,
    startedAt: _startedAt,
    completedAt: DateTime.now(),
  );

  // Simpan semua — tidak perlu await berurutan
  await Future.wait([
    _resultService.saveQuizSession(session),
    _resultService.addPointsToUser(uid, pointsEarned),
    _progressService.saveProgress(uid, currentCategory!.id, ProgressModel(
      categoryId: currentCategory!.id,
      categoryName: currentCategory!.name,
      imagePath: currentCategory!.imagePath,
      bestScore: percentage.round(),
      lastScore: percentage.round(),
      attempts: 1,
      lastProgress: totalQuestions,
      totalQuestions: totalQuestions,
      isCompleted: true,
    )),
    // LeaderboardService.updateLeaderboardEntry → dikerjakan di Fase 5
  ]);

  // Refresh data user di AuthController
  await _authController.refreshUser();
}
```

---

### `home_controller.dart` — Load Progress

```dart
// Tambahkan:
final ProgressService _progressService = ProgressService();
final userProgress = <ProgressModel>[].obs;
final lastActivity = Rxn<ProgressModel>();

// Tambahkan di onInit():
fetchUserProgress();

Future<void> fetchUserProgress() async {
  final uid = Get.find<AuthController>().uid;
  if (uid == null) return;
  try {
    final progress = await _progressService.getAllProgress(uid);
    userProgress.value = progress;
    lastActivity.value = progress.isNotEmpty ? progress.first : null;
  } catch (e) {
    // Non-critical, tidak perlu snackbar
  }
}
```

---

### `home_view.dart` — Reminder Card Dinamis

```dart
// _buildReminderCard() — UBAH dari hardcode ke:
Obx(() {
  final last = controller.lastActivity.value;
  if (last == null) return const SizedBox.shrink(); // atau placeholder
  return _buildReminderCard(
    title: last.categoryName,
    subtitle: 'Terakhir: ${last.lastScore}%',
    progress: last.lastProgress,
    total: last.totalQuestions,
  );
})
```

---

## 🗄️ STRUKTUR FIRESTORE FASE 4

```
quiz_sessions/{auto-id}
  userId, categoryId, categoryName
  totalQuestions, correctAnswers, wrongAnswers
  pointsEarned, percentage, grade
  streak, isCompleted, startedAt, completedAt

user_progress/{uid}/categories/{categoryId}
  categoryId, categoryName, imagePath
  bestScore, lastScore, attempts
  lastProgress, totalQuestions
  isCompleted, lastPlayedAt
```

---

## ✅ CHECKLIST FASE 4

```
✅ Buat lib/shared/models/quiz_session_model.dart
✅ Buat lib/shared/models/progress_model.dart
✅ Buat lib/shared/services/quiz_result_service.dart
✅ Buat lib/shared/services/progress_service.dart
✅ Update quiz_controller.dart (simpan hasil setelah quiz selesai)
✅ Update home_controller.dart (load progress user)
✅ Update home_view.dart (reminder card & aktivitas terakhir dinamis)
✅ Update home_view.dart (total poin dari AuthController)
⬜ Test: selesaikan quiz → cek quiz_sessions di Firestore Console
⬜ Test: poin user bertambah di Firestore users/{uid}
⬜ Test: progress muncul di HomeView reminder cards
⬜ Test: quiz kedua kali → bestScore terupdate jika lebih tinggi
```
