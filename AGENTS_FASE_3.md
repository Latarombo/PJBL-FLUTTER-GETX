# ⬜ FASE 3 — Quiz dari Firestore
> Baca `AGENTS.md` (core) terlebih dahulu, lalu baca file ini.
> Status: **STANDBY** — kerjakan setelah Fase 2 selesai & ter-checklist semua.
> Tujuan: Pindahkan data soal dari hardcode `quiz_data.dart` ke Firestore.

---

## 🎯 TUJUAN FASE INI

- `categories` collection di Firestore berisi 6 kategori
- `questions` collection di Firestore berisi 90 soal
- HomeView menampilkan kategori dinamis dari Firestore (bukan hardcode)
- QuizController fetch soal dari Firestore (bukan `QuizData.getQuizByCategory`)
- Header nama user di HomeView dari `AuthController.username`
- `quiz_data.dart` dihapus setelah migrasi selesai

---

## ❌ KONDISI SAAT INI (Yang Harus Diubah)

```dart
// quiz_controller.dart — hardcode
quizSession = QuizData.getQuizByCategory(category);

// home_view.dart — kategori hardcode
_buildCategoryCard('Tarian Tradisional', 'assets/images/tarian_adat.png'),
_buildCategoryCard('Makanan Nusantara', 'assets/images/makanan_nusantara.png'),
// ...dll semua hardcode

// home_view.dart — reminder card hardcode
_buildReminderCard(title: 'Kuis 1', subtitle: 'Pakaian Adat...', progress: 9, ...)

// home_view.dart — nama user hardcode
const Text('Jhon Doe')
```

---

## 📁 FILE BARU YANG HARUS DIBUAT

### 1. `lib/shared/models/category_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;           // Firestore document ID
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
      totalQuestions: data['totalQuestions'] ?? 0,
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
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
```

---

### 2. `lib/shared/models/question_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Menggantikan QuizQuestion di quiz_model.dart
class QuestionModel {
  final String id;            // Firestore document ID
  final String categoryId;    // ref ke categories/{id}
  final String categoryName;
  final String question;
  final List<String> options; // ["A. Aceh", "B. Bali", ...]
  final int correctIndex;     // index jawaban benar (0-based)
  final String? imageUrl;     // path assets atau null
  final bool isActive;

  const QuestionModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.imageUrl,
    this.isActive = true,
  });

  // Helper
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctIndex: data['correctIndex'] ?? 0,
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
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
```

---

### 3. `lib/shared/services/quiz_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/question_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil semua kategori aktif — dipakai HomeController
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

  // Ambil soal berdasarkan categoryId — dipakai QuizController
  Future<List<QuestionModel>> getQuestionsByCategoryId(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .get();
      final questions = snapshot.docs.map(QuestionModel.fromFirestore).toList();
      questions.shuffle(); // urutan soal acak tiap sesi
      return questions;
    } catch (e) {
      throw Exception('Gagal mengambil soal: $e');
    }
  }

  // Ambil satu kategori berdasarkan nama — dipakai QuizController saat tap kategori
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
}
```

---

## 📝 FILE YANG HARUS DIUPDATE

### `home_controller.dart` — Fetch Kategori dari Firestore

```dart
// Tambahkan imports & dependencies:
final QuizService _quizService = QuizService();

// Tambahkan state:
final isLoadingCategories = false.obs;
final categories = <CategoryModel>[].obs;

// Tambahkan di onInit():
@override
void onInit() {
  super.onInit();
  fetchCategories();
}

// Tambahkan method:
Future<void> fetchCategories() async {
  try {
    isLoadingCategories.value = true;
    final result = await _quizService.getActiveCategories();
    categories.value = result;
  } catch (e) {
    Get.snackbar('Error', 'Gagal memuat kategori',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoadingCategories.value = false;
  }
}
```

---

### `home_view.dart` — Kategori & Username Dinamis

```dart
// _buildGameCategories() — UBAH dari hardcode ke:
Obx(() {
  if (controller.isLoadingCategories.value) {
    return const CircularProgressIndicator();
  }
  return ListView.builder(
    itemCount: controller.categories.length,
    itemBuilder: (_, i) {
      final cat = controller.categories[i];
      return _buildCategoryCard(cat.name, cat.imagePath);
      // atau sesuaikan dengan widget yang sudah ada
    },
  );
})

// Header nama user — UBAH dari:
const Text('Jhon Doe')
// MENJADI:
Obx(() => Text(Get.find<AuthController>().username))

// _buildReminderCard() — akan dinamis di Fase 4
// Untuk Fase 3, boleh hide dulu atau tampilkan placeholder
```

---

### `quiz_controller.dart` — Fetch Soal dari Firestore

```dart
// Tambahkan:
final QuizService _quizService = QuizService();
final isLoading = false.obs;
final questions = <QuestionModel>[].obs;

// Ubah onInit() — dari:
quizSession = QuizData.getQuizByCategory(category); // ← HAPUS INI

// MENJADI:
@override
void onInit() {
  super.onInit();
  final categoryName = Get.arguments as String? ?? '';
  fetchQuestions(categoryName);
}

Future<void> fetchQuestions(String categoryName) async {
  try {
    isLoading.value = true;
    final category = await _quizService.getCategoryByName(categoryName);
    if (category == null) {
      Get.snackbar('Error', 'Kategori tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final result = await _quizService.getQuestionsByCategoryId(category.id);
    questions.value = result;
    // reset state quiz
    currentIndex.value = 0;
    selectedAnswer.value = -1;
    // dst...
  } catch (e) {
    Get.snackbar('Error', 'Gagal memuat soal',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
```

---

## 🗄️ DATA MIGRASI KE FIRESTORE

### Collection: `categories` (6 dokumen)

```
ID (auto)  │ name                      │ imagePath
───────────┼───────────────────────────┼────────────────────────────────
auto       │ Tarian Tradisional        │ assets/images/tarian_adat.png
auto       │ Pakaian Adat Nusantara    │ assets/images/pakaian_adat.png
auto       │ Rumah Adat Nusantara      │ assets/images/rumah_adat.png
auto       │ Musik Tradisional         │ assets/images/musik_tradisional.png
auto       │ Senjata Tradisional       │ assets/images/senjata_tradisional.png
auto       │ Makanan Nusantara         │ assets/images/makanan_nusantara.png
```

### Collection: `questions` (90 dokumen)

```
Semua soal dari quiz_data.dart dipindah ke sini.
Perubahan field:
  correctAnswerIndex → correctIndex  (rename)
  category (String)  → categoryId   (ID dari collection categories)
```

> 💡 **Tips Migrasi:** Buat Dart script satu kali (`tool/migrate_quiz_data.dart`)
> yang membaca `quiz_data.dart` dan upload ke Firestore.
> Jalankan sekali, lalu hapus script-nya.

---

## ✅ CHECKLIST FASE 3

```
✅ Buat lib/shared/models/category_model.dart
✅ Buat lib/shared/models/question_model.dart
✅ Buat lib/shared/services/quiz_service.dart
✅ Input 6 kategori ke Firestore (via Firebase Console atau script)
✅ Input 90 soal ke Firestore (via script Dart)
✅ Update home_controller.dart (fetchCategories)
✅ Update home_view.dart (kategori dinamis + username dari AuthController)
✅ Update quiz_controller.dart (fetch soal dari Firestore)
✅ Update quiz_model.dart (sesuaikan dengan QuestionModel baru jika perlu)
✅ Hapus quiz_data.dart setelah semua soal berhasil di Firestore
⬜ Test: kategori muncul di HomeView dari Firestore
⬜ Test: soal muncul di QuizView dari Firestore
⬜ Test: soal ter-shuffle tiap sesi baru
⬜ Test: nama user muncul di header HomeView
```
