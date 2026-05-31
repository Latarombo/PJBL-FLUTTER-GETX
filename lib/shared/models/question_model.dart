import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? imageUrl;
  final bool isActive;

  /// 'Mudah' / 'Sedang' / 'Sulit'
  /// Default 'Mudah' agar kompatibel dengan data lama
  final String difficulty;

  /// Nomor card tempat soal ini digunakan (1-10).
  /// Null berarti data lama yang belum di-assign ke card tertentu.
  final int? cardNumber;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuestionModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.imageUrl,
    this.isActive = true,
    this.difficulty = 'Mudah',
    this.cardNumber,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] ?? true,
      difficulty: data['difficulty'] as String? ?? 'Mudah',
      cardNumber: (data['cardNumber'] as num?)?.toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'imageUrl': imageUrl,
    'isActive': isActive,
    'difficulty': difficulty,
    'cardNumber': cardNumber,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'stats': {'timesAnswered': 0, 'timesWrong': 0, 'wrongRate': 0.0},
  };
}
