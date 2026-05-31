import 'package:cloud_firestore/cloud_firestore.dart';

/// Status sebuah card di KategoriKuisView
enum CardStatus {
  locked, // belum bisa dimainkan
  available, // bisa dimainkan (tanda tanya) — belum pernah selesai
  completed, // sudah 100% benar (centang) — TIDAK DIPAKAI LANGSUNG di onCardTap
  replay, // sudah selesai tapi bisa dikerjakan ulang (poin = 0)
}

/// Definisi satu card di grid KategoriKuis
class CardDefinition {
  final int cardNumber; // 1-10
  final String level; // 'Mudah' / 'Sedang' / 'Sulit'
  final int totalSoal; // 10 / 15 / 20

  const CardDefinition({
    required this.cardNumber,
    required this.level,
    required this.totalSoal,
  });
}

/// Semua definisi card untuk satu kategori (10 card total)
/// Card 1-5  → Mudah  (10 soal)
/// Card 6-8  → Sedang (15 soal)
/// Card 9-10 → Sulit  (20 soal)
const List<CardDefinition> kCardDefinitions = [
  CardDefinition(cardNumber: 1, level: 'Mudah', totalSoal: 10),
  CardDefinition(cardNumber: 2, level: 'Mudah', totalSoal: 10),
  CardDefinition(cardNumber: 3, level: 'Mudah', totalSoal: 10),
  CardDefinition(cardNumber: 4, level: 'Mudah', totalSoal: 10),
  CardDefinition(cardNumber: 5, level: 'Mudah', totalSoal: 10),
  CardDefinition(cardNumber: 6, level: 'Sedang', totalSoal: 15),
  CardDefinition(cardNumber: 7, level: 'Sedang', totalSoal: 15),
  CardDefinition(cardNumber: 8, level: 'Sedang', totalSoal: 15),
  CardDefinition(cardNumber: 9, level: 'Sulit', totalSoal: 20),
  CardDefinition(cardNumber: 10, level: 'Sulit', totalSoal: 20),
];

/// Progress user untuk satu card di satu kategori
/// Doc path: category_card_progress/{uid}_{categoryId}_{cardNumber}
class CategoryCardProgress {
  final String uid;
  final String categoryId;
  final int cardNumber;

  /// List soal yang sudah dijawab BENAR (by question id)
  final List<String> correctQuestionIds;

  /// True jika semua soal di card ini sudah benar 100%
  final bool isCompleted;

  /// Jumlah sesi yang pernah dimainkan
  final int attempts;

  final DateTime? lastPlayedAt;

  const CategoryCardProgress({
    required this.uid,
    required this.categoryId,
    required this.cardNumber,
    required this.correctQuestionIds,
    required this.isCompleted,
    this.attempts = 0,
    this.lastPlayedAt,
  });

  /// Doc ID: "{uid}_{categoryId}_{cardNumber}"
  static String docId(String uid, String categoryId, int cardNumber) =>
      '${uid}_${categoryId}_$cardNumber';

  factory CategoryCardProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryCardProgress(
      uid: data['uid'] ?? '',
      categoryId: data['categoryId'] ?? '',
      cardNumber: (data['cardNumber'] as num?)?.toInt() ?? 1,
      correctQuestionIds: List<String>.from(data['correctQuestionIds'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
      attempts: (data['attempts'] as num?)?.toInt() ?? 0,
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'categoryId': categoryId,
    'cardNumber': cardNumber,
    'correctQuestionIds': correctQuestionIds,
    'isCompleted': isCompleted,
    'attempts': attempts,
    'lastPlayedAt': lastPlayedAt != null
        ? Timestamp.fromDate(lastPlayedAt!)
        : FieldValue.serverTimestamp(),
  };

  CategoryCardProgress copyWith({
    List<String>? correctQuestionIds,
    bool? isCompleted,
    int? attempts,
    DateTime? lastPlayedAt,
  }) => CategoryCardProgress(
    uid: uid,
    categoryId: categoryId,
    cardNumber: cardNumber,
    correctQuestionIds: correctQuestionIds ?? this.correctQuestionIds,
    isCompleted: isCompleted ?? this.isCompleted,
    attempts: attempts ?? this.attempts,
    lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
  );
}

/// ViewModel: card definition + status + progress
class CardWithStatus {
  final CardDefinition definition;
  final CardStatus status;
  final CategoryCardProgress? progress;

  const CardWithStatus({
    required this.definition,
    required this.status,
    this.progress,
  });

  int get cardNumber => definition.cardNumber;
  String get level => definition.level;
  int get totalSoal => definition.totalSoal;

  /// True jika card ini sudah pernah diselesaikan (poin akan 0 jika dimainkan ulang)
  bool get isAlreadyCompleted => progress?.isCompleted == true;

  /// Soal yang sudah benar di sesi sebelumnya
  List<String> get previouslyCorrectIds => progress?.correctQuestionIds ?? [];
}
