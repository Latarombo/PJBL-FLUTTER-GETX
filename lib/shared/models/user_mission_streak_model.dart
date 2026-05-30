import 'package:cloud_firestore/cloud_firestore.dart';

class UserMissionStreakModel {
  final String uid;
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;
  final bool badgeEarned;
  final DateTime? badgeEarnedAt;
  final int totalMissionsDone;
  final Map<String, int> dailyCompletions;

  const UserMissionStreakModel({
    required this.uid,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    required this.badgeEarned,
    this.badgeEarnedAt,
    required this.totalMissionsDone,
    required this.dailyCompletions,
  });

  factory UserMissionStreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserMissionStreakModel(
      uid: data['uid'] ?? doc.id,
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longest_streak'] as num?)?.toInt() ?? 0,
      lastCompletedDate: data['last_completed_date'] as String?,
      badgeEarned: data['badge_earned'] ?? false,
      badgeEarnedAt: (data['badge_earned_at'] as Timestamp?)?.toDate(),
      totalMissionsDone: (data['total_missions_done'] as num?)?.toInt() ?? 0,
      dailyCompletions: Map<String, int>.from(
        (data['daily_completions'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_completed_date': lastCompletedDate,
    'badge_earned': badgeEarned,
    'badge_earned_at': badgeEarnedAt != null
        ? Timestamp.fromDate(badgeEarnedAt!)
        : null,
    'total_missions_done': totalMissionsDone,
    'daily_completions': dailyCompletions,
  };
}
