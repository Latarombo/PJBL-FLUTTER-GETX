import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:santarana/shared/models/weekly_mission_model.dart';

class WeeklyMissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Helper: WIB now ───────────────────────────────────────────
  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  // ── Helper: Senin minggu ini jam 00:00 WIB ────────────────────
  DateTime _getMondayOfWeek(DateTime date) {
    final wib = date.toUtc().add(const Duration(hours: 7));
    final daysFromMonday = wib.weekday - 1; // Monday = 1
    final monday = DateTime(wib.year, wib.month, wib.day - daysFromMonday);
    // Konversi ke UTC untuk disimpan ke Firestore
    return monday.subtract(const Duration(hours: 7));
  }

  // ── Helper: week key "yyyy-Www" ───────────────────────────────
  String _getWeekKey(DateTime date) {
    final wib = date.toUtc().add(const Duration(hours: 7));
    final weekNumber = _getWeekNumber(wib);
    return '${wib.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.weekday <= 4
        ? startOfYear.subtract(Duration(days: startOfYear.weekday - 1))
        : startOfYear.add(Duration(days: 8 - startOfYear.weekday));
    final diff = date.difference(firstMonday).inDays;
    return (diff / 7).floor() + 1;
  }

  // ── Helper: pilih template set berdasarkan rotasi ─────────────
  Future<String> _getTemplateSet(int weekNumber) async {
    final snap = await _db.collection('weekly_mission_templates').get();

    if (snap.docs.isEmpty) return 'set_1';

    final sets = snap.docs.map((d) => d.id).toList()..sort();
    final index = (weekNumber - 1) % sets.length;
    return sets[index];
  }

  // ── Week key saat ini ─────────────────────────────────────────
  String get currentWeekKey => _getWeekKey(_nowWib);

  // ── Stream dokumen mingguan ───────────────────────────────────
  Stream<WeeklyMissionDocument?> weeklyMissionStream() {
    return _db
        .collection('weekly_missions')
        .doc(currentWeekKey)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return null;
          return WeeklyMissionDocument.fromFirestore(snap);
        });
  }

  // ── Generate dokumen mingguan jika belum ada ──────────────────
  Future<void> generateWeekIfNeeded() async {
    final weekKey = currentWeekKey;
    final docRef = _db.collection('weekly_missions').doc(weekKey);
    final snap = await docRef.get();
    if (snap.exists) return;

    final now = _nowWib;
    final weekNumber = _getWeekNumber(now);
    final templateSet = await _getTemplateSet(weekNumber);

    // Ambil missions dari template
    final missionsSnap = await _db
        .collection('weekly_mission_templates')
        .doc(templateSet)
        .collection('missions')
        .orderBy('day')
        .get();

    if (missionsSnap.docs.isEmpty) return;

    // Hitung Senin minggu ini jam 00:00 WIB (dalam UTC)
    final mondayUtc = _getMondayOfWeek(DateTime.now());

    final slots = <Map<String, dynamic>>[];

    for (final doc in missionsSnap.docs) {
      final data = doc.data();
      final day = (data['day'] as num?)?.toInt() ?? 1;

      // unlock: Senin + (day-1) hari jam 00:00 WIB
      final unlockAt = mondayUtc.add(Duration(days: day - 1));

      // expires: Senin + day hari jam 00:00 WIB
      final expiresAt = mondayUtc.add(Duration(days: day));

      slots.add(
        WeeklyMissionSlot(
          day: day,
          templateId: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          difficulty: data['difficulty'] ?? 'Mudah',
          rewardPoints: (data['reward_points'] as num?)?.toInt() ?? 10,
          isSpecial: data['is_special'] ?? false,
          imagePath: data['image_path'] as String?,
          unlockAt: unlockAt,
          expiresAt: expiresAt,
        ).toMap(),
      );
    }

    // weekStart = Senin 00:00 WIB, weekEnd = Minggu 23:59 WIB
    final weekStart = mondayUtc;
    final weekEnd = mondayUtc
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));

    await docRef.set({
      'week': weekKey,
      'week_start': Timestamp.fromDate(weekStart),
      'week_end': Timestamp.fromDate(weekEnd),
      'template_set': templateSet,
      'missions': slots,
    });
  }

  // ── Ambil completion user minggu ini ──────────────────────────
  Future<UserWeeklyCompletion?> getThisWeekCompletion(String uid) async {
    final docId = UserWeeklyCompletion.docId(uid, currentWeekKey);
    final snap = await _db
        .collection('user_weekly_completions')
        .doc(docId)
        .get();
    if (!snap.exists) return null;
    return UserWeeklyCompletion.fromFirestore(snap);
  }

  // ── Tandai misi selesai ───────────────────────────────────────
  Future<void> completeMission({
    required String uid,
    required int day,
    required int rewardPoints,
    required int totalMissionsInWeek,
  }) async {
    final week = currentWeekKey;
    final docId = UserWeeklyCompletion.docId(uid, week);
    final completionRef = _db.collection('user_weekly_completions').doc(docId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(completionRef);

      List<int> completedDays = [];
      int pointsThisWeek = 0;
      int currentStreak = 0;

      if (snap.exists) {
        final existing = UserWeeklyCompletion.fromFirestore(snap);

        // Sudah selesai misi ini minggu ini → skip
        if (existing.completedDays.contains(day)) return;

        completedDays = List<int>.from(existing.completedDays);
        pointsThisWeek = existing.pointsEarnedThisWeek;
        currentStreak = existing.currentStreak;
      }

      completedDays.add(day);
      completedDays.sort();
      pointsThisWeek += rewardPoints;

      // Hitung streak: cek apakah hari-hari berurutan tanpa skip
      currentStreak = _calculateStreak(completedDays);

      final allCompleted = completedDays.length >= totalMissionsInWeek;

      tx.set(completionRef, {
        'uid': uid,
        'week': week,
        'completed_days': completedDays,
        'current_streak': currentStreak,
        'all_completed': allCompleted,
        'points_earned_this_week': pointsThisWeek,
        'last_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Tambah poin ke user
      tx.update(_db.collection('users').doc(uid), {
        'totalPoints': FieldValue.increment(rewardPoints),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── Hitung streak berdasarkan hari yang sudah selesai ─────────
  // Streak = jumlah hari berurutan dari hari 1 tanpa skip
  int _calculateStreak(List<int> completedDays) {
    if (completedDays.isEmpty) return 0;

    int streak = 0;
    for (int i = 1; i <= 7; i++) {
      if (completedDays.contains(i)) {
        streak++;
      } else {
        break; // ada yang skip → streak berhenti
      }
    }
    return streak;
  }
}
