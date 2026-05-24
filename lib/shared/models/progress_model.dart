import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String categoryId;
  final String categoryName;
  final String imagePath;
  final int bestScore;       // persentase terbaik 0-100
  final int lastScore;       // persentase terakhir
  final int attempts;        // berapa kali main
  final int lastProgress;    // soal terakhir dijawab (misal: 15 dari 15)
  final int totalQuestions;  // 15
  final bool isCompleted;    // pernah selesai sampai soal terakhir
  final DateTime? lastPlayedAt;

  const ProgressModel({
    required this.categoryId,
    required this.categoryName,
    required this.imagePath,
    required this.bestScore,
    required this.lastScore,
    required this.attempts,
    required this.lastProgress,
    required this.totalQuestions,
    required this.isCompleted,
    this.lastPlayedAt,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      categoryId: data['categoryId'] ?? doc.id,
      categoryName: data['categoryName'] ?? '',
      imagePath: data['imagePath'] ?? '',
      bestScore: (data['bestScore'] as num?)?.toInt() ?? 0,
      lastScore: (data['lastScore'] as num?)?.toInt() ?? 0,
      attempts: (data['attempts'] as num?)?.toInt() ?? 0,
      lastProgress: (data['lastProgress'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 15,
      isCompleted: data['isCompleted'] ?? false,
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'imagePath': imagePath,
        'bestScore': bestScore,
        'lastScore': lastScore,
        'attempts': attempts,
        'lastProgress': lastProgress,
        'totalQuestions': totalQuestions,
        'isCompleted': isCompleted,
        'lastPlayedAt': lastPlayedAt != null
            ? Timestamp.fromDate(lastPlayedAt!)
            : FieldValue.serverTimestamp(),
      };
}