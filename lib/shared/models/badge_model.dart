import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String
  conditionType; // 'streak', 'first_quiz', 'category_card1', 'category_all_cards'
  final String? categoryId; // null jika tidak terkait kategori
  final bool isActive;
  final DateTime? createdAt;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.conditionType,
    this.categoryId,
    this.isActive = true,
    this.createdAt,
  });

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BadgeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      conditionType: data['conditionType'] ?? '',
      categoryId: data['categoryId'] as String?,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'conditionType': conditionType,
    'categoryId': categoryId,
    'isActive': isActive,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class EarnedBadgeModel {
  final String badgeId;
  final DateTime earnedAt;

  const EarnedBadgeModel({required this.badgeId, required this.earnedAt});

  factory EarnedBadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EarnedBadgeModel(
      badgeId: doc.id,
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'earnedAt': FieldValue.serverTimestamp(),
  };
}
