import 'package:cloud_firestore/cloud_firestore.dart';

class UserMissionCompletionModel {
  final String uid;
  final String date;
  final List<int> completedMissions;
  final int pointsEarnedToday;
  final bool all7Completed;
  final DateTime? lastUpdatedAt;

  const UserMissionCompletionModel({
    required this.uid,
    required this.date,
    required this.completedMissions,
    required this.pointsEarnedToday,
    required this.all7Completed,
    this.lastUpdatedAt,
  });

  // Doc ID: "{uid}_{yyyy-MM-dd}"
  static String docId(String uid, String date) => '${uid}_$date';

  factory UserMissionCompletionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserMissionCompletionModel(
      uid: data['uid'] ?? '',
      date: data['date'] ?? '',
      completedMissions: List<int>.from(
        (data['completed_missions'] as List<dynamic>? ?? []).map(
          (e) => (e as num).toInt(),
        ),
      ),
      pointsEarnedToday: (data['points_earned_today'] as num?)?.toInt() ?? 0,
      all7Completed: data['all_7_completed'] ?? false,
      lastUpdatedAt: (data['last_updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'date': date,
    'completed_missions': completedMissions,
    'points_earned_today': pointsEarnedToday,
    'all_7_completed': all7Completed,
    'last_updated_at': FieldValue.serverTimestamp(),
  };
}
