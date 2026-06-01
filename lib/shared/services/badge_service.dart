import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/badge_model.dart';

class BadgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Ambil SEMUA badge termasuk yang isActive: false ───────────
  // Digunakan untuk menampilkan grid di ProfileView
  Future<List<BadgeModel>> getAllBadgesIncludingInactive() async {
    final snap = await _db.collection('medals').get(); // tanpa filter isActive
    return snap.docs.map(BadgeModel.fromFirestore).toList();
  }

  // ── Ambil hanya badge aktif (untuk logika award) ──────────────
  // Digunakan untuk checkAndAwardBadgeAfterQuiz
  Future<List<BadgeModel>> getAllBadges() async {
    final snap = await _db
        .collection('medals')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map(BadgeModel.fromFirestore).toList();
  }

  Future<List<EarnedBadgeModel>> getEarnedBadges(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('earned_badges')
        .get();
    return snap.docs.map(EarnedBadgeModel.fromFirestore).toList(); // ← ganti
  }

  Future<void> awardBadge({
    required String uid,
    required String badgeId,
  }) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('earned_badges')
        .doc(badgeId);

    final existing = await ref.get();
    if (existing.exists) return;

    await ref.set({'earnedAt': FieldValue.serverTimestamp()});
  }

  Future<void> checkAndAwardBadgeAfterQuiz({
    required String uid,
    required String categoryId,
    required bool isFirstEverQuiz,
    required bool isCard1Completed,
    required bool isAllCardsCompleted,
  }) async {
    final badges = await getAllBadges();

    for (final badge in badges) {
      switch (badge.conditionType) {
        case 'first_quiz':
          if (isFirstEverQuiz) {
            await awardBadge(uid: uid, badgeId: badge.id);
          }
          break;

        case 'category_card1':
          if (badge.categoryId == categoryId && isCard1Completed) {
            await awardBadge(uid: uid, badgeId: badge.id);
          }
          break;

        case 'category_all_cards':
          if (badge.categoryId == categoryId && isAllCardsCompleted) {
            await awardBadge(uid: uid, badgeId: badge.id);
          }
          break;
      }
    }
  }

  Future<void> checkAndAwardStreakBadge(String uid) async {
    final badges = await getAllBadges();
    for (final badge in badges) {
      if (badge.conditionType == 'streak') {
        await awardBadge(uid: uid, badgeId: badge.id);
      }
    }
  }
}
