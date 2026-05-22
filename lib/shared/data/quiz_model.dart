/// Model untuk pertanyaan quiz - Prinsip Parameterized
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl; // Optional - bisa null jika tidak ada gambar
  final String category;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl, // Optional parameter
    required this.category,
  });

  // Helper getter untuk cek apakah pertanyaan punya gambar
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

/// Model untuk quiz session
class QuizSession {
  final String id;
  final String title;
  final String category;
  final List<QuizQuestion> questions;
  final int totalQuestions;
  final String? imagePath;

  QuizSession({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    required this.totalQuestions,
    this.imagePath,
  });
}

/// Model untuk quiz result
class QuizResult {
  final int correctAnswers;
  final int totalQuestions;
  final int pointsEarned;
  final DateTime completedAt;

  QuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.completedAt,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
  
  String get grade {
    if (percentage >= 90) return 'Sempurna!';
    if (percentage >= 80) return 'Sangat Baik!';
    if (percentage >= 70) return 'Baik';
    if (percentage >= 60) return 'Cukup';
    return 'Perlu Belajar Lagi';
  }
}