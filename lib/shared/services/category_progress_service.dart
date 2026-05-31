import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/category_progress_model.dart';
import 'package:santarana/shared/models/question_model.dart';

/// CategoryProgressService
/// ────────────────────────────────────────────────────────────
/// Bertanggung jawab atas:
/// 1. Ambil progress semua card untuk satu kategori (per user)
/// 2. Simpan/update progress setelah sesi quiz selesai
/// 3. Hitung poin baru (hanya dari soal yang belum pernah benar)
///
/// Collection: category_card_progress
/// Doc ID   : {uid}_{categoryId}_{cardNumber}
class CategoryProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 1. AMBIL SEMUA PROGRESS UNTUK SATU KATEGORI ──────────────────────────
  Future<Map<int, CategoryCardProgress>> getAllCardProgress({
    required String uid,
    required String categoryId,
  }) async {
    try {
      final snapshot = await _db
          .collection('category_card_progress')
          .where('uid', isEqualTo: uid)
          .where('categoryId', isEqualTo: categoryId)
          .get();

      final result = <int, CategoryCardProgress>{};
      for (final doc in snapshot.docs) {
        final progress = CategoryCardProgress.fromFirestore(doc);
        result[progress.cardNumber] = progress;
      }
      return result;
    } catch (e) {
      throw Exception('Gagal mengambil progress kategori: $e');
    }
  }

  // ── 2. HITUNG POIN BARU (hanya soal yang belum pernah benar) ─────────────
  ///
  /// [answeredCorrectly] = map questionId → true/false hasil sesi ini
  /// [previouslyCorrectIds] = soal yang sudah benar di sesi sebelumnya
  ///
  /// Return: {newPoints, newlyCorrectIds}
  Map<String, dynamic> calculateNewPoints({
    required Map<String, bool> answeredCorrectly,
    required List<String> previouslyCorrectIds,
    required int pointsPerQuestion,
  }) {
    final newlyCorrect = <String>[];

    for (final entry in answeredCorrectly.entries) {
      final questionId = entry.key;
      final isCorrect = entry.value;

      // Hanya hitung poin jika benar DAN belum pernah benar sebelumnya
      if (isCorrect && !previouslyCorrectIds.contains(questionId)) {
        newlyCorrect.add(questionId);
      }
    }

    return {
      'newPoints': newlyCorrect.length * pointsPerQuestion,
      'newlyCorrectIds': newlyCorrect,
    };
  }

  // ── 3. SIMPAN PROGRESS SETELAH SESI SELESAI ──────────────────────────────
  ///
  /// Merge dengan progress lama:
  /// - correctQuestionIds: union (gabungan, tanpa duplikat)
  /// - isCompleted: true jika semua soal di card sudah benar
  /// - attempts: increment +1
  Future<CategoryCardProgress> saveCardProgress({
    required String uid,
    required String categoryId,
    required int cardNumber,
    required int totalSoalInCard,
    required Map<String, bool> answeredCorrectly,
    required CategoryCardProgress? existingProgress,
  }) async {
    try {
      final docId = CategoryCardProgress.docId(uid, categoryId, cardNumber);
      final docRef = _db.collection('category_card_progress').doc(docId);

      // Gabungkan soal yang sudah benar sebelumnya + yang baru benar
      final previousIds = existingProgress?.correctQuestionIds ?? [];
      final newlyCorrect = answeredCorrectly.entries
          .where((e) => e.value && !previousIds.contains(e.key))
          .map((e) => e.key)
          .toList();

      final allCorrectIds = [...previousIds, ...newlyCorrect];
      final isCompleted = allCorrectIds.length >= totalSoalInCard;
      final attempts = (existingProgress?.attempts ?? 0) + 1;

      final updated = CategoryCardProgress(
        uid: uid,
        categoryId: categoryId,
        cardNumber: cardNumber,
        correctQuestionIds: allCorrectIds,
        isCompleted: isCompleted,
        attempts: attempts,
        lastPlayedAt: DateTime.now(),
      );

      await docRef.set({
        ...updated.toFirestore(),
        'lastPlayedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return updated;
    } catch (e) {
      throw Exception('Gagal menyimpan progress card: $e');
    }
  }

  // ── 4. BUILD STATUS SEMUA CARD (computed dari progress) ─────────────────
  ///
  /// Aturan status:
  /// - Card yang sudah isCompleted → status [replay]
  ///   (bisa dikerjakan ulang, tapi poin = 0 karena semua soal sudah benar)
  /// - Card 1 selalu available jika belum completed
  /// - Card N available jika card N-1 sudah isCompleted
  /// - Selain itu → locked
  List<CardWithStatus> buildCardsWithStatus(
    Map<int, CategoryCardProgress> progressMap,
  ) {
    final result = <CardWithStatus>[];

    for (int i = 0; i < kCardDefinitions.length; i++) {
      final def = kCardDefinitions[i];
      final cardNum = def.cardNumber;
      final progress = progressMap[cardNum];

      CardStatus status;

      if (progress?.isCompleted == true) {
        // Sudah diselesaikan → bisa replay (poin 0)
        status = CardStatus.replay;
      } else if (cardNum == 1) {
        // Card 1 selalu bisa dimainkan
        status = CardStatus.available;
      } else {
        // Card N available jika card N-1 completed
        final prevProgress = progressMap[cardNum - 1];
        status = (prevProgress?.isCompleted == true)
            ? CardStatus.available
            : CardStatus.locked;
      }

      result.add(
        CardWithStatus(definition: def, status: status, progress: progress),
      );
    }

    return result;
  }

  // ── 5. AMBIL SOAL UNTUK LEVEL TERTENTU ────────────────────────────────────
  ///
  /// Filter dari semua soal aktif berdasarkan level/difficulty
  List<QuestionModel> filterByLevel(
    List<QuestionModel> allQuestions,
    String level,
  ) {
    final filtered = allQuestions
        .where((q) => q.difficulty.toLowerCase() == level.toLowerCase())
        .toList();
    filtered.shuffle();
    return filtered;
  }
}
