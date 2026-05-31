import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/question_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── CATEGORIES ────────────────────────────────────────────────────────────

  /// Ambil semua kategori aktif → dipakai HomeController
  Future<List<CategoryModel>> getActiveCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.map(CategoryModel.fromFirestore).toList();
    } catch (e) {
      throw Exception('Gagal mengambil kategori: $e');
    }
  }

  /// Ambil satu kategori berdasarkan nama → dipakai QuizController
  Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return CategoryModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Gagal mengambil kategori: $e');
    }
  }

  // ─── QUESTIONS ─────────────────────────────────────────────────────────────

  /// Ambil semua soal aktif berdasarkan categoryId.
  /// Dipakai di mode lama (HomeView) dan sebagai fallback.
  Future<List<QuestionModel>> getQuestionsByCategoryId(
    String categoryId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();

      final questions = snapshot.docs.map(QuestionModel.fromFirestore).toList();

      questions.shuffle();
      return questions;
    } catch (e) {
      throw Exception('Gagal mengambil soal: $e');
    }
  }

  /// Ambil soal untuk card tertentu berdasarkan categoryId + cardNumber.
  ///
  /// Return map:
  ///   - 'questions' : List<QuestionModel> — soal yang ditemukan (sudah di-shuffle)
  ///   - 'isEnough'  : bool — true jika jumlah soal >= [requiredCount]
  ///   - 'found'     : int  — jumlah soal yang ditemukan di Firestore
  ///
  /// Tidak melempar Exception agar controller bisa handle snackbar sendiri.
  Future<Map<String, dynamic>> getQuestionsByCard({
    required String categoryId,
    required int cardNumber,
    required int requiredCount,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('categoryId', isEqualTo: categoryId)
          .where('cardNumber', isEqualTo: cardNumber)
          .where('isActive', isEqualTo: true)
          .get();

      final questions = snapshot.docs.map(QuestionModel.fromFirestore).toList();

      questions.shuffle();

      return {
        'questions': questions,
        'isEnough': questions.length >= requiredCount,
        'found': questions.length,
      };
    } catch (e) {
      throw Exception('Gagal mengambil soal card $cardNumber: $e');
    }
  }
}
