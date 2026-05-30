import 'package:cloud_firestore/cloud_firestore.dart';

// ── Status computed client-side ──────────────────────────────────────────────
enum DailyMissionStatus { locked, inProgress, completed, expired }

// ── Satu slot misi dalam dokumen daily_missions ───────────────────────────────
class MissionSlot {
  final String templateId;
  final int missionNumber;
  final String title;
  final String description;
  final String difficulty;
  final int rewardPoints;
  final bool isSpecial;
  final String? imagePath;
  final DateTime unlockAt;
  final DateTime expiresAt;

  const MissionSlot({
    required this.templateId,
    required this.missionNumber,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.rewardPoints,
    required this.isSpecial,
    this.imagePath,
    required this.unlockAt,
    required this.expiresAt,
  });

  factory MissionSlot.fromMap(Map<String, dynamic> data) {
    return MissionSlot(
      templateId: data['template_id'] ?? '',
      missionNumber: (data['mission_number'] as num?)?.toInt() ?? 1,
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
    'template_id': templateId,
    'mission_number': missionNumber,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'reward_points': rewardPoints,
    'is_special': isSpecial,
    'image_path': imagePath,
    'unlock_at': Timestamp.fromDate(unlockAt),
    'expires_at': Timestamp.fromDate(expiresAt),
  };

  // ── Computed status (tidak disimpan ke Firestore) ─────────────────────────
  DailyMissionStatus computeStatus({
    required DateTime now,
    required bool isCompleted,
  }) {
    if (isCompleted) return DailyMissionStatus.completed;
    if (now.isBefore(unlockAt)) return DailyMissionStatus.locked;
    if (now.isAfter(expiresAt)) return DailyMissionStatus.expired;
    return DailyMissionStatus.inProgress;
  }
}

// ── Dokumen harian (daily_missions/{yyyy-MM-dd}) ──────────────────────────────
class DailyMissionDocument {
  final String date;
  final DateTime resetAt;
  final DateTime nextResetAt;
  final List<MissionSlot> missions;
  final int completedCount;

  const DailyMissionDocument({
    required this.date,
    required this.resetAt,
    required this.nextResetAt,
    required this.missions,
    this.completedCount = 0,
  });

  factory DailyMissionDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawMissions = (data['missions'] as List<dynamic>?) ?? [];
    return DailyMissionDocument(
      date: data['date'] ?? doc.id,
      resetAt: (data['reset_at'] as Timestamp).toDate(),
      nextResetAt: (data['next_reset_at'] as Timestamp).toDate(),
      missions: rawMissions
          .map((m) => MissionSlot.fromMap(m as Map<String, dynamic>))
          .toList(),
      completedCount: (data['completed_count'] as num?)?.toInt() ?? 0,
    );
  }
}
