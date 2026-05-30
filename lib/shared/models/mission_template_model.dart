import 'package:cloud_firestore/cloud_firestore.dart';

class MissionTemplateModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int missionNumber;
  final int unlockHour;
  final int rewardPoints;
  final bool isSpecial;
  final bool isActive;
  final String? imagePath;
  final DateTime? createdAt;

  const MissionTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.missionNumber,
    required this.unlockHour,
    required this.rewardPoints,
    required this.isSpecial,
    required this.isActive,
    this.imagePath,
    this.createdAt,
  });

  factory MissionTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionTemplateModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Mudah',
      missionNumber: (data['mission_number'] as num?)?.toInt() ?? 1,
      unlockHour: (data['unlock_hour'] as num?)?.toInt() ?? 0,
      rewardPoints: (data['reward_points'] as num?)?.toInt() ?? 10,
      isSpecial: data['is_special'] ?? false,
      isActive: data['is_active'] ?? true,
      imagePath: data['image_path'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'mission_number': missionNumber,
    'unlock_hour': unlockHour,
    'reward_points': rewardPoints,
    'is_special': isSpecial,
    'is_active': isActive,
    'image_path': imagePath,
    'created_at': FieldValue.serverTimestamp(),
  };
}
