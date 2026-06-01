import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:santarana/shared/models/daily_mission_model.dart';
import 'package:santarana/shared/models/mission_template_model.dart';
import 'package:santarana/shared/models/user_mission_completion_model.dart';
import 'package:santarana/shared/models/user_mission_streak_model.dart';
import 'package:santarana/shared/services/badge_service.dart';

class DailyMissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BadgeService _badgeService = BadgeService();
  // ── Helper: tanggal hari ini sebagai string "yyyy-MM-dd" WIB ──────────────
  String get todayKey {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateFormat('yyyy-MM-dd').format(now);
  }

  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  // ── 1. STREAM dokumen harian (real-time, untuk UI) ────────────────────────
  Stream<DailyMissionDocument?> dailyMissionStream() {
    return _db.collection('daily_missions').doc(todayKey).snapshots().map((
      snap,
    ) {
      if (!snap.exists) return null;
      return DailyMissionDocument.fromFirestore(snap);
    });
  }

  // ── 2. GENERATE dokumen harian jika belum ada ─────────────────────────────
  Future<void> generateTodayIfNeeded() async {
    final docRef = _db.collection('daily_missions').doc(todayKey);
    final snap = await docRef.get();
    if (snap.exists) return;

    final templatesSnap = await _db
        .collection('daily_mission_templates')
        .where('is_active', isEqualTo: true)
        .orderBy('mission_number')
        .get();

    if (templatesSnap.docs.isEmpty) return;

    final templates = templatesSnap.docs
        .map(MissionTemplateModel.fromFirestore)
        .toList();

    final now = _nowWib;
    final resetAt = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(hours: 7));
    final nextResetAt = resetAt.add(const Duration(days: 1));

    final slots = <Map<String, dynamic>>[];
    for (int i = 0; i < templates.length; i++) {
      final t = templates[i];
      final unlockAt = DateTime.utc(
        now.year,
        now.month,
        now.day,
        t.unlockHour,
      ).subtract(const Duration(hours: 7));

      DateTime expiresAt;
      if (i < templates.length - 1) {
        final nextTemplate = templates[i + 1];
        expiresAt = DateTime.utc(
          now.year,
          now.month,
          now.day,
          nextTemplate.unlockHour,
        ).subtract(const Duration(hours: 7));
      } else {
        expiresAt = nextResetAt;
      }

      slots.add(
        MissionSlot(
          templateId: t.id,
          missionNumber: t.missionNumber,
          title: t.title,
          description: t.description,
          difficulty: t.difficulty,
          rewardPoints: t.rewardPoints,
          isSpecial: t.isSpecial,
          imagePath: t.imagePath,
          unlockAt: unlockAt,
          expiresAt: expiresAt,
        ).toMap(),
      );
    }

    await docRef.set({
      'date': todayKey,
      'reset_at': Timestamp.fromDate(resetAt),
      'next_reset_at': Timestamp.fromDate(nextResetAt),
      'completed_count': 0,
      'missions': slots,
    });
  }

  // ── 3. AMBIL completion user hari ini ─────────────────────────────────────
  Future<UserMissionCompletionModel?> getTodayCompletion(String uid) async {
    final docId = UserMissionCompletionModel.docId(uid, todayKey);
    final snap = await _db
        .collection('user_mission_completions')
        .doc(docId)
        .get();
    if (!snap.exists) return null;
    return UserMissionCompletionModel.fromFirestore(snap);
  }

  // ── 4. TANDAI misi selesai ────────────────────────────────────────────────
  Future<void> completeMission({
    required String uid,
    required int missionNumber,
    required int rewardPoints,
    required int totalMissionsInDay,
  }) async {
    final date = todayKey;
    final docId = UserMissionCompletionModel.docId(uid, date);
    final completionRef = _db.collection('user_mission_completions').doc(docId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(completionRef);

      List<int> completedList = [];
      int pointsToday = 0;

      if (snap.exists) {
        final existing = UserMissionCompletionModel.fromFirestore(snap);
        if (existing.completedMissions.contains(missionNumber)) return;
        completedList = List<int>.from(existing.completedMissions);
        pointsToday = existing.pointsEarnedToday;
      }

      completedList.add(missionNumber);
      pointsToday += rewardPoints;
      final all7 = completedList.length >= totalMissionsInDay;

      tx.set(completionRef, {
        'uid': uid,
        'date': date,
        'completed_missions': completedList,
        'points_earned_today': pointsToday,
        'all_7_completed': all7,
        'last_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.update(_db.collection('users').doc(uid), {
        'totalPoints': FieldValue.increment(rewardPoints),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      if (all7) {
        _updateStreakAfterCompletion(uid, date);
      }
    });
  }

  // ── 5. UPDATE STREAK ──────────────────────────────────────────────────────
  Future<void> _updateStreakAfterCompletion(
    String uid,
    String completedDate,
  ) async {
    final streakRef = _db.collection('user_mission_streaks').doc(uid);
    final snap = await streakRef.get();

    int currentStreak = 1;
    int longestStreak = 1;
    bool badgeEarned = false;
    DateTime? badgeEarnedAt;

    if (snap.exists) {
      final existing = UserMissionStreakModel.fromFirestore(snap);
      final yesterday = _getYesterdayKey();
      final isConsecutive = existing.lastCompletedDate == yesterday;

      currentStreak = isConsecutive ? existing.currentStreak + 1 : 1;
      longestStreak = currentStreak > existing.longestStreak
          ? currentStreak
          : existing.longestStreak;
      badgeEarned = existing.badgeEarned;
      badgeEarnedAt = existing.badgeEarnedAt;

      // ── Step 7: Award streak badge setelah 7 hari ────────────
      if (currentStreak >= 7 && !badgeEarned) {
        badgeEarned = true;
        badgeEarnedAt = DateTime.now();

        await Future.wait([
          // Update field di users
          _db.collection('users').doc(uid).update({
            'missionBadgeEarned': true,
            'missionBadgeEarnedAt': FieldValue.serverTimestamp(),
          }),
          // Award badge via BadgeService
          _badgeService.checkAndAwardStreakBadge(uid),
        ]);
      }
    }

    await streakRef.set({
      'uid': uid,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': completedDate,
      'badge_earned': badgeEarned,
      'badge_earned_at': badgeEarnedAt != null
          ? Timestamp.fromDate(badgeEarnedAt)
          : null,
      'total_missions_done': FieldValue.increment(1),
      'daily_completions.$completedDate': 7,
    }, SetOptions(merge: true));
  }

  // ── 6. AMBIL STREAK USER ──────────────────────────────────────────────────
  Future<UserMissionStreakModel?> getUserStreak(String uid) async {
    final snap = await _db.collection('user_mission_streaks').doc(uid).get();
    if (!snap.exists) return null;
    return UserMissionStreakModel.fromFirestore(snap);
  }

  // ── Helper: kemarin dalam format "yyyy-MM-dd" ─────────────────────────────
  String _getYesterdayKey() {
    final yesterday = _nowWib.subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }
}
