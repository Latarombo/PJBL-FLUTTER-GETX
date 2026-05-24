import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSessionModel {
  final String? id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int pointsEarned;
  final double percentage;
  final String grade;
  final int streak;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime completedAt;

  const QuizSessionModel({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.pointsEarned,
    required this.percentage,
    required this.grade,
    required this.streak,
    required this.isCompleted,
    required this.startedAt,
    required this.completedAt,
  });

  // Helper: hitung grade dari persentase
  static String calculateGrade(double percentage) {
    if (percentage >= 100) return 'Sempurna!';
    if (percentage >= 80) return 'Sangat Baik!';
    if (percentage >= 60) return 'Baik!';
    if (percentage >= 40) return 'Cukup';
    return 'Perlu Belajar Lagi';
  }

  // Helper: hitung poin dari jawaban benar (10 poin per jawaban benar)
  static int calculatePoints(int correctAnswers) => correctAnswers * 10;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'pointsEarned': pointsEarned,
        'percentage': percentage,
        'grade': grade,
        'streak': streak,
        'isCompleted': isCompleted,
        'startedAt': Timestamp.fromDate(startedAt),
        'completedAt': Timestamp.fromDate(completedAt),
      };

  factory QuizSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizSessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      correctAnswers: (data['correctAnswers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (data['wrongAnswers'] as num?)?.toInt() ?? 0,
      pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0.0,
      grade: data['grade'] ?? '',
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }
}