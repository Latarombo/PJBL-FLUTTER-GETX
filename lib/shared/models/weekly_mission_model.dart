import 'package:cloud_firestore/cloud_firestore.dart';

enum WeeklyMissionStatus { locked, inProgress, completed, expired }

// ── Satu slot misi mingguan ───────────────────────────────────
class WeeklyMissionSlot {
  final int day; // 1-7
  final String templateId;
  final String title;
  final String description;
  final String difficulty;
  final int rewardPoints;
  final bool isSpecial;
  final String? imagePath;
  final DateTime unlockAt; // jam 00:00 WIB hari ke-N
  final DateTime expiresAt; // jam 00:00 WIB hari ke-(N+1)

  const WeeklyMissionSlot({
    required this.day,
    required this.templateId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.rewardPoints,
    required this.isSpecial,
    this.imagePath,
    required this.unlockAt,
    required this.expiresAt,
  });

  factory WeeklyMissionSlot.fromMap(Map<String, dynamic> data) {
    return WeeklyMissionSlot(
      day: (data['day'] as num?)?.toInt() ?? 1,
      templateId: data['template_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Mudah',
      rewardPoints: (data['reward_points'] as num?)?.toInt() ?? 10,
      isSpecial: data['is_special'] ?? false,
      imagePath: data['image_path'] as String?,
      unlockAt: (data['unlock_at'] as Timestamp).toDate(),
      expiresAt: (data['expires_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'day': day,
    'template_id': templateId,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'reward_points': rewardPoints,
    'is_special': isSpecial,
    'image_path': imagePath,
    'unlock_at': Timestamp.fromDate(unlockAt),
    'expires_at': Timestamp.fromDate(expiresAt),
  };

  // ── Computed status ───────────────────────────────────────────
  WeeklyMissionStatus computeStatus({
    required DateTime now,
    required bool isCompleted,
    required bool isSpecialLocked, // khusus misi 7
  }) {
    if (isCompleted) return WeeklyMissionStatus.completed;
    if (isSpecial && isSpecialLocked) return WeeklyMissionStatus.locked;
    if (now.isBefore(unlockAt)) return WeeklyMissionStatus.locked;
    if (now.isAfter(expiresAt)) return WeeklyMissionStatus.expired;
    return WeeklyMissionStatus.inProgress;
  }
}

// ── Dokumen mingguan weekly_missions/{yyyy-Www} ───────────────
class WeeklyMissionDocument {
  final String week; // "2026-W23"
  final DateTime weekStart; // Senin 00:00 WIB
  final DateTime weekEnd; // Minggu 23:59 WIB
  final String templateSet; // "set_1"
  final List<WeeklyMissionSlot> missions;

  const WeeklyMissionDocument({
    required this.week,
    required this.weekStart,
    required this.weekEnd,
    required this.templateSet,
    required this.missions,
  });

  factory WeeklyMissionDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawMissions = (data['missions'] as List<dynamic>?) ?? [];
    return WeeklyMissionDocument(
      week: data['week'] ?? doc.id,
      weekStart: (data['week_start'] as Timestamp).toDate(),
      weekEnd: (data['week_end'] as Timestamp).toDate(),
      templateSet: data['template_set'] ?? 'set_1',
      missions: rawMissions
          .map((m) => WeeklyMissionSlot.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Progress user per minggu ──────────────────────────────────
class UserWeeklyCompletion {
  final String uid;
  final String week;
  final List<int> completedDays; // [1, 2, 3]
  final int currentStreak; // streak dalam minggu ini
  final bool allCompleted; // semua 7 misi selesai
  final int pointsEarnedThisWeek;
  final DateTime? lastUpdatedAt;

  const UserWeeklyCompletion({
    required this.uid,
    required this.week,
    required this.completedDays,
    required this.currentStreak,
    required this.allCompleted,
    required this.pointsEarnedThisWeek,
    this.lastUpdatedAt,
  });

  static String docId(String uid, String week) => '${uid}_$week';

  // Cek apakah misi 1-6 sudah semua selesai (syarat misi special)
  bool get canDoSpecialMission =>
      completedDays.contains(1) &&
      completedDays.contains(2) &&
      completedDays.contains(3) &&
      completedDays.contains(4) &&
      completedDays.contains(5) &&
      completedDays.contains(6);

  factory UserWeeklyCompletion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserWeeklyCompletion(
      uid: data['uid'] ?? '',
      week: data['week'] ?? '',
      completedDays: List<int>.from(
        (data['completed_days'] as List<dynamic>? ?? []).map(
          (e) => (e as num).toInt(),
        ),
      ),
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      allCompleted: data['all_completed'] ?? false,
      pointsEarnedThisWeek:
          (data['points_earned_this_week'] as num?)?.toInt() ?? 0,
      lastUpdatedAt: (data['last_updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'week': week,
    'completed_days': completedDays,
    'current_streak': currentStreak,
    'all_completed': allCompleted,
    'points_earned_this_week': pointsEarnedThisWeek,
    'last_updated_at': FieldValue.serverTimestamp(),
  };
}

// ── ViewModel: slot + computed status ────────────────────────
class WeeklyMissionSlotWithStatus {
  final WeeklyMissionSlot slot;
  final WeeklyMissionStatus status;

  const WeeklyMissionSlotWithStatus({required this.slot, required this.status});
}
