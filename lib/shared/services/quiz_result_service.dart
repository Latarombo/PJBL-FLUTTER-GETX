import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/quiz_session_model.dart';

// ⚠️ Service rules: tidak ada navigasi, tidak ada Get.snackbar
// Lempar Exception jika gagal — biarkan Controller yang handle
class QuizResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── SIMPAN SESI QUIZ ──────────────────────────────────────────────────────

  /// Simpan hasil quiz ke collection 'quiz_sessions'
  Future<void> saveQuizSession(QuizSessionModel session) async {
    try {
      await _firestore
          .collection('quiz_sessions')
          .add(session.toFirestore());
    } catch (e) {
      throw Exception('Gagal menyimpan hasil quiz: $e');
    }
  }

  // ─── UPDATE POIN USER ──────────────────────────────────────────────────────

  /// Update totalPoints & quizCompleted user secara atomic
  /// Menggunakan FieldValue.increment agar aman dari race condition
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

  // ─── UPDATE STATS SOAL ─────────────────────────────────────────────────────

  /// Update stats soal setelah setiap sesi selesai
  /// Non-critical: gagal tidak boleh menghentikan flow utama
  Future<void> updateQuestionStats(
      String questionId, bool isWrong) async {
    try {
      final ref = _firestore.collection('questions').doc(questionId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        final stats =
            snapshot.data()?['stats'] as Map<String, dynamic>? ?? {};
        final timesAnswered = ((stats['timesAnswered'] as num?) ?? 0).toInt() + 1;
        final timesWrong =
            ((stats['timesWrong'] as num?) ?? 0).toInt() + (isWrong ? 1 : 0);
        final wrongRate = timesAnswered > 0
            ? (timesWrong / timesAnswered) * 100
            : 0.0;
        transaction.update(ref, {
          'stats.timesAnswered': timesAnswered,
          'stats.timesWrong': timesWrong,
          'stats.wrongRate': wrongRate,
        });
      });
    } catch (e) {
      // Non-critical — hanya log, jangan throw
      // ignore: avoid_print
      print('Warning: gagal update stats soal $questionId: $e');
    }
  }
}