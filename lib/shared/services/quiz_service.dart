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

  /// Ambil satu kategori berdasarkan nama → dipakai QuizController saat tap kategori
  /// Cocok dengan nama yang dikirim dari HomeView (e.g. "Tarian Tradisional")
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

  /// Ambil soal berdasarkan categoryId → dipakai QuizController
  /// Query menggunakan categoryId (document ID dari categories)
  /// Contoh: categoryId = "JV2plSlwye9y74tE87or"
  Future<List<QuestionModel>> getQuestionsByCategoryId(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();

      final questions = snapshot.docs
          .map(QuestionModel.fromFirestore)
          .toList();

      // Shuffle agar urutan soal acak setiap sesi baru
      questions.shuffle();
      return questions;
    } catch (e) {
      throw Exception('Gagal mengambil soal: $e');
    }
  }
}