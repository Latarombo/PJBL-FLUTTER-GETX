import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/progress_model.dart';

// ⚠️ Service rules: tidak ada navigasi, tidak ada Get.snackbar
class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Path subcollection: user_progress/{uid}/categories/{categoryId}

  // ─── SIMPAN PROGRESS ───────────────────────────────────────────────────────

  /// Simpan atau update progress per kategori
  /// Menggunakan merge:true agar tidak overwrite data lain
  /// Khusus bestScore: hanya update jika skor baru lebih tinggi
  Future<void> saveProgress(
      String uid, String categoryId, ProgressModel newProgress) async {
    try {
      final ref = _firestore
          .collection('user_progress')
          .doc(uid)
          .collection('categories')
          .doc(categoryId);

      // Ambil data lama untuk bandingkan bestScore
      final existing = await ref.get();

      int bestScore = newProgress.lastScore;
      int attempts = newProgress.attempts;

      if (existing.exists) {
        final oldData = existing.data()!;
        final oldBest = (oldData['bestScore'] as num?)?.toInt() ?? 0;
        final oldAttempts = (oldData['attempts'] as num?)?.toInt() ?? 0;

        // bestScore hanya update jika skor baru lebih tinggi
        bestScore =
            newProgress.lastScore > oldBest ? newProgress.lastScore : oldBest;
        // attempts akumulatif
        attempts = oldAttempts + 1;
      }

      await ref.set(
        {
          'categoryId': newProgress.categoryId,
          'categoryName': newProgress.categoryName,
          'imagePath': newProgress.imagePath,
          'bestScore': bestScore,
          'lastScore': newProgress.lastScore,
          'attempts': attempts,
          'lastProgress': newProgress.lastProgress,
          'totalQuestions': newProgress.totalQuestions,
          'isCompleted': newProgress.isCompleted,
          'lastPlayedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Gagal menyimpan progress: $e');
    }
  }

  // ─── AMBIL SEMUA PROGRESS ──────────────────────────────────────────────────

  /// Ambil semua progress user, diurutkan dari yang paling baru
  /// Digunakan di HomeController untuk reminder card
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

  // ─── AMBIL SATU PROGRESS ───────────────────────────────────────────────────

  /// Ambil progress satu kategori
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

  // ─── AMBIL AKTIVITAS TERAKHIR ──────────────────────────────────────────────

  /// Ambil progress kategori yang paling terakhir dimainkan
  /// Digunakan di HomeController untuk card "Aktivitas Terakhir"
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
      // Non-critical — return null jika gagal
      return null;
    }
  }
}