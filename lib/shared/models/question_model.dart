import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;            // Firestore document ID (auto-generated)
  final String categoryId;    // ref ke categories/{id}  ← "JV2plSlwye9y74tE87or"
  final String categoryName;  // "Senjata Tradisional"
  final String question;      // teks soal
  final List<String> options; // ["A. Keris", "B. Mandau", ...]
  final int correctIndex;     // index jawaban benar (0-based) ← correctIndex
  final String? imageUrl;     // path assets atau null
  final bool isActive;
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
    this.createdAt,
    this.updatedAt,
  });

  // Helper: cek apakah soal punya gambar
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      question: data['question'] ?? '',
      // Firestore menyimpan options sebagai List<dynamic> → cast ke List<String>
      options: List<String>.from(data['options'] ?? []),
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] ?? true,
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
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'stats': {
      'timesAnswered': 0,
      'timesWrong': 0,
      'wrongRate': 0.0,
    },
  };
}