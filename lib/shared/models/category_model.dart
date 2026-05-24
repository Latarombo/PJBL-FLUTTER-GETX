import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;           // Firestore document ID (auto-generated)
  final String name;         // "Tarian Tradisional"
  final String description;
  final String imagePath;    // "assets/images/tarian_adat.png"
  final int totalQuestions;  // 15
  final bool isActive;
  final String createdBy;    // uid Admin
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.totalQuestions,
    this.isActive = true,
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'totalQuestions': totalQuestions,
    'isActive': isActive,
    'createdBy': createdBy,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}