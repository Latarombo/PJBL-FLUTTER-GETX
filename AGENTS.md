# 🏛️ SantaraNa — AI Vibe Coding Master Document
> **Baca dokumen ini SEPENUHNYA sebelum menulis satu baris kode pun.**
> Firebase + Flutter + GetX | Project: `santarana-quiz`
> SDK: Dart `^3.10.7` | Flutter terbaru

---

## 🚨 ATURAN WAJIB — JANGAN DILANGGAR

```
1. SELALU gunakan GetX untuk state management — DILARANG pakai setState/StatefulWidget
2. SELALU gunakan GetView<Controller> untuk semua halaman
3. SELALU gunakan Get.snackbar() untuk notifikasi — BUKAN ScaffoldMessenger
4. SELALU gunakan Get.toNamed() / Get.offAllNamed() untuk navigasi
5. SELALU pisahkan logika ke Controller & Service — View hanya UI
6. DILARANG menulis logika bisnis di dalam View/Widget
7. DILARANG menggunakan BuildContext untuk navigasi
8. SELALU buat loading state dengan .obs di Controller
9. SELALU handle error dengan try-catch di Service layer
10. JANGAN ubah file theme, widget, atau route yang tidak diminta
```

---

## 📦 STACK & DEPENDENCIES

### pubspec.yaml (Dependencies Aktif)
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.3                    # State management & navigation
  firebase_core: ^4.9.0          # Firebase core
  firebase_auth: ^6.5.1          # Authentication
  cloud_firestore: ^6.4.1        # Database
  curved_navigation_bar: ^1.0.6  # Bottom nav
  google_fonts: ^8.0.0           # Font Poppins
  flutter_svg: ^2.0.10           # SVG support
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.13.1
  flutter_test:
    sdk: flutter
```

### Import Pattern yang Dipakai di Project Ini
```dart
// GetX — GUNAKAN import spesifik seperti di bawah (sudah ada di project)
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

// ATAU gunakan wildcard untuk file baru (lebih simpel)
import 'package:get/get.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Package name project
import 'package:santarana/...';
```

---

## 🏗️ ARSITEKTUR & POLA KODE

### Struktur Folder Saat Ini
```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── app_shell.dart              # Bottom navigation shell
│   ├── app_shell_binding.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── modules/
│       ├── splash/
│       ├── sign_in/
│       ├── register/
│       ├── forgot_password/
│       ├── email_verification/
│       ├── password_recovery_success/
│       ├── home/
│       ├── quiz/
│       ├── leaderboard/
│       ├── profile/
│       └── settings/
└── shared/
    ├── data/
    │   ├── quiz_data.dart          # AKAN DIHAPUS di Fase 3
    │   └── quiz_model.dart
    ├── theme/                      # JANGAN DIUBAH
    │   ├── app_colors.dart
    │   ├── app_theme.dart
    │   └── ... (file lainnya)
    └── widgets/                    # JANGAN DIUBAH
        ├── app_buttons.dart
        ├── app_input_field.dart
        └── ...
```

### Pattern Controller (Contoh Nyata dari Project)
```dart
// POLA YANG BENAR — ikuti ini
class SignInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;        // reactive state pakai .obs

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;

  void handleSignIn() {
    // validasi dulu
    if (usernameController.text.isEmpty) {
      Get.snackbar('Gagal', 'Username tidak boleh kosong',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // navigasi pakai GetX
    Get.offAllNamed(Routes.APP);
  }

  void goToRegister() => Get.toNamed(Routes.REGISTER);

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }
}
```

### Pattern View (Contoh Nyata dari Project)
```dart
// POLA YANG BENAR — ikuti ini
class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Obx(() => Column(      // Obx untuk bagian yang reaktif
        children: [
          InputField(
            controller: controller.usernameController,  // akses via controller
            hint: 'Username',
          ),
          // ...
        ],
      )),
    );
  }
}
```

### Pattern Binding (Contoh Nyata dari Project)
```dart
class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}
```

### Pattern Routes (Contoh Nyata dari Project)
```dart
// app_routes.dart — Routes yang sudah ada
static const SPLASH = '/';
static const SIGN_IN = '/sign-in';
static const REGISTER = '/register';
static const FORGOT_PASSWORD = '/forgot-password';
static const EMAIL_VERIFICATION = '/email-verification';
static const PASSWORD_RECOVERY_SUCCESS = '/password-recovery-success';
static const APP = '/app';
static const HOME = '/home';
static const QUIZ = '/quiz';
static const LEADERBOARD = '/leaderboard';
static const PROFILE = '/profile';
static const SETTINGS = '/settings';
```

---

## 🎨 DESIGN SYSTEM (JANGAN DIUBAH)

### Warna Utama (dari app_colors.dart)
```dart
AppColors.background    = Color(0xFFF9F4E4)   // cream — background semua halaman
AppColors.backgroundAlt = Color(0xFFFFF8E7)   // cream alt
AppColors.dark          = Color(0xFF1A2332)   // warna primary button
AppColors.accent        = Color(0xFFFFB347)   // orange — progress bar
AppColors.textPrimary   = Color(0xff270f0f)   // teks utama
AppColors.navBar        = Color(0xFFFFDDB3)   // bottom nav
AppColors.navBarActive  = Color(0xFFE8B88A)   // nav active
AppColors.navBarIcon    = Color(0xFF8B5A3C)   // nav icon
```

### Widget yang Sudah Ada (Gunakan Ini, Jangan Buat Baru)
```dart
PrimaryButton(text: 'Masuk', onPressed: () {})         // tombol primary
InputField(controller: ctrl, hint: 'Email')            // input field
SocialLoginButton(text: '...', iconPath: '...', ...)   // tombol sosial
OtpInput(length: 4, onCompleted: (otp) {})             // input OTP
```

### Snackbar Pattern (SELALU Pakai Ini)
```dart
// Success
Get.snackbar('Berhasil', 'Pesan sukses',
    backgroundColor: Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM);

// Error
Get.snackbar('Error', 'Pesan error',
    backgroundColor: Colors.red,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM);

// Warning
Get.snackbar('Peringatan', 'Pesan warning',
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM);
```

---

## 📍 STATUS PROGRESS

```
✅ FASE 1 — Setup Firebase      → SELESAI
🔄 FASE 2 — Auth & User         → SEDANG DIKERJAKAN
⬜ FASE 3 — Quiz dari Firestore
⬜ FASE 4 — Hasil Quiz & Progress
⬜ FASE 5 — Leaderboard Real-time
⬜ FASE 6 — Profile & Settings
⬜ FASE 7 — Security & Finishing
```

---

## ✅ FASE 1 — Setup Firebase (SELESAI)

### Yang Sudah Ada
- Firebase project: `santarana-quiz`
- Firebase Auth: Email/Password aktif
- Firestore: region `asia-southeast1`
- `firebase_options.dart` sudah di-generate
- `main.dart` sudah diupdate

### main.dart Saat Ini
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase connected: ${Firebase.app().name}'); // ← HAPUS di Fase 7
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
```

---

## 🔄 FASE 2 — Auth & User

### Tujuan
Mengganti semua login/register dummy menjadi nyata menggunakan Firebase Auth + Firestore.

### Kondisi Saat Ini (Yang Perlu Diubah)
```dart
// sign_in_controller.dart — SEKARANG (dummy)
void handleSignIn() {
  // tidak ada validasi ke Firebase sama sekali
  Get.snackbar('Berhasil', 'Selamat datang...');
  Get.offAllNamed(Routes.APP);  // langsung masuk tanpa auth
}

// register_controller.dart — SEKARANG (dummy)
void handleRegister() {
  // tidak menyimpan ke Firestore sama sekali
  Get.snackbar('Berhasil', 'Registrasi berhasil!...');
  Get.offAllNamed(Routes.APP);
}

// splash_controller.dart — SEKARANG (tidak cek auth)
Future<void> _startFlow() async {
  // langsung ke SIGN_IN tanpa cek apakah user sudah login
  Get.offAllNamed(Routes.SIGN_IN);
}

// profile_controller.dart — SEKARANG (dummy logout)
void logout() {
  Get.offAllNamed(Routes.SIGN_IN); // tidak logout dari Firebase
}
```

### File Baru yang Harus Dibuat

#### 1. `lib/shared/models/user_model.dart`
```dart
// Model ini merepresentasikan dokumen di Firestore collection 'users'
class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;           // 'user' | 'admin' | 'superadmin'
  final String? avatarUrl;
  final int totalPoints;
  final int rank;
  final double correctRate;    // persentase benar 0.0 - 100.0
  final int quizCompleted;
  final int streak;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  // Constructor, copyWith, fromFirestore, toFirestore
  // fromFirestore: factory dari DocumentSnapshot
  // toFirestore: Map<String, dynamic> untuk disimpan ke Firestore
}
```

#### 2. `lib/shared/services/auth_service.dart`
```dart
// Service ini HANYA mengurus Firebase Auth + operasi user di Firestore
// TIDAK boleh ada navigasi Get.toNamed() di sini
// Navigasi adalah tanggung jawab Controller

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter user yang sedang login
  User? get currentUser => _auth.currentUser;

  // Stream perubahan auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login — lempar Exception jika gagal
  Future<UserModel> signIn(String email, String password)

  // Register — buat akun Auth + simpan dokumen di Firestore 'users'
  // role default = 'user'
  Future<UserModel> register(String email, String username, String password)

  // Logout
  Future<void> signOut()

  // Kirim email reset password
  Future<void> sendPasswordReset(String email)

  // Ambil data user dari Firestore berdasarkan uid
  Future<UserModel?> getUserData(String uid)
}
```

#### 3. `lib/shared/controllers/auth_controller.dart`
```dart
// GetxService — didaftarkan sekali di main.dart, hidup sepanjang app
// Tugasnya: menyimpan state user yang sedang login agar bisa diakses
// dari mana saja via Get.find<AuthController>()

class AuthController extends GetxService {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Getters yang sering dipakai
  bool get isLoggedIn => currentUser.value != null;
  String get username => currentUser.value?.username ?? '';
  String get role => currentUser.value?.role ?? 'user';
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';
  int get totalPoints => currentUser.value?.totalPoints ?? 0;
  int get rank => currentUser.value?.rank ?? 0;

  // Refresh data user dari Firestore
  Future<void> refreshUser()

  // Set user setelah login/register
  void setUser(UserModel user)

  // Clear user setelah logout
  void clearUser()
}
```

### File yang Harus Diupdate

#### `sign_in_controller.dart` — Perubahan Kunci
```dart
// SEBELUM: langsung navigasi tanpa auth
// SESUDAH: pakai AuthService, handle loading & error

class SignInController extends GetxController {
  // Tambahkan:
  final AuthService _authService = AuthService();
  final isLoading = false.obs;   // ← BARU: loading state

  // handleSignIn() — UBAH menjadi:
  // 1. Validasi input (tetap sama)
  // 2. Set isLoading = true
  // 3. Panggil _authService.signIn(email, password)
  //    CATATAN: field input di view adalah 'Username'
  //    tapi Firebase Auth butuh email
  //    → Perlu keputusan: login pakai email atau username?
  //    → REKOMENDASI: ganti hint field menjadi 'Email' agar konsisten
  // 4. Set user ke AuthController
  // 5. Navigasi ke Routes.APP
  // 6. Handle error di catch block → Get.snackbar error
  // 7. Set isLoading = false di finally
}
```

> ⚠️ **CATATAN PENTING Fase 2:**
> `SignInView` saat ini punya field `hint: 'Username'` tapi Firebase Auth
> butuh email untuk login. Ada 2 pilihan:
> - **Opsi A:** Ganti hint field menjadi 'Email' (direkomendasikan, lebih simpel)
> - **Opsi B:** Simpan username di Firestore, query email berdasarkan username
>   (lebih kompleks, perlu query tambahan)

#### `register_controller.dart` — Perubahan Kunci
```dart
// SESUDAH:
// 1. Validasi semua field (tetap sama)
// 2. Set isLoading = true
// 3. Panggil _authService.register(email, username, password)
//    → Ini akan membuat akun Firebase Auth
//    → Sekaligus menyimpan dokumen ke Firestore 'users'
//    → role otomatis = 'user'
// 4. Set user ke AuthController
// 5. Navigasi ke Routes.APP
// 6. Handle error di catch block → Get.snackbar error
```

#### `forgot_password_controller.dart` — Perubahan Kunci
```dart
// SESUDAH:
// validEmailSubmit() → panggil _authService.sendPasswordReset(email)
// Firebase akan kirim email reset password otomatis
// Tidak perlu OTP manual lagi — tapi tampilan email_verification_view
// tetap ada, cukup tampilkan pesan "cek email Anda"
// ATAU bisa skip email_verification dan langsung
// tampilkan pesan sukses di forgot_password_view
```

#### `splash_controller.dart` — Perubahan Kunci
```dart
// SESUDAH _startFlow():
// Cek Firebase Auth apakah ada user yang sudah login
// Jika sudah login → langsung Get.offAllNamed(Routes.APP)
// Jika belum login → Get.offAllNamed(Routes.SIGN_IN)
// Animasi splash tetap jalan dulu sebelum cek

Future<void> _startFlow() async {
  await fadeController.forward();
  await Future.delayed(const Duration(milliseconds: 800));
  await slideController.forward();
  await Future.delayed(const Duration(milliseconds: 2800));

  // CEK AUTH STATE — BARU
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // load data user dulu
    Get.offAllNamed(Routes.APP);
  } else {
    Get.offAllNamed(Routes.SIGN_IN);
  }
}
```

#### `profile_controller.dart` — Perubahan Kunci
```dart
// logout() SESUDAH:
// 1. Tampilkan dialog konfirmasi (tetap sama)
// 2. Jika Keluar ditekan:
//    - Panggil _authService.signOut()
//    - Panggil AuthController.clearUser()
//    - Get.offAllNamed(Routes.SIGN_IN)
```

### Struktur Firestore: Collection `users`
```
users/
  {uid}/
    uid            : String       ← sama dengan Firebase Auth UID
    username       : String       ← "Najwa_Miniww"
    email          : String       ← "najwa@email.com"
    role           : String       ← "user" (default saat register)
    avatarUrl      : String?      ← null (belum ada fitur upload)
    totalPoints    : Number       ← 0 (bertambah setiap quiz selesai)
    rank           : Number       ← 0 (diupdate saat leaderboard diquery)
    correctRate    : Number       ← 0.0 (rata-rata % benar)
    quizCompleted  : Number       ← 0 (jumlah quiz yang diselesaikan)
    streak         : Number       ← 0 (hari berturut-turut main)
    lastActiveAt   : Timestamp    ← saat login/main quiz
    createdAt      : Timestamp    ← saat register
```

### Error Messages Standar Fase 2
```dart
// Firebase Auth Error → terjemahkan ke Bahasa Indonesia
'user-not-found'        → 'Email tidak terdaftar'
'wrong-password'        → 'Password salah'
'email-already-in-use'  → 'Email sudah terdaftar'
'weak-password'         → 'Password terlalu lemah'
'invalid-email'         → 'Format email tidak valid'
'network-request-failed'→ 'Tidak ada koneksi internet'
// Default                → 'Terjadi kesalahan, coba lagi'
```

### Checklist Fase 2
```
⬜ Buat lib/shared/models/user_model.dart
⬜ Buat lib/shared/services/auth_service.dart
⬜ Buat lib/shared/controllers/auth_controller.dart
⬜ Daftarkan AuthController di main.dart sebagai GetxService
⬜ Update sign_in_controller.dart
⬜ Update register_controller.dart
⬜ Update forgot_password_controller.dart
⬜ Update splash_controller.dart (cek auth state)
⬜ Update profile_controller.dart (logout nyata)
⬜ Test: register user baru → cek di Firebase console
⬜ Test: login dengan akun yang baru dibuat
⬜ Test: splash langsung ke APP jika sudah login
⬜ Test: logout → kembali ke sign_in
```

---

## ⬜ FASE 3 — Quiz dari Firestore

### Tujuan
Pindahkan data soal dari `quiz_data.dart` (hardcode) ke Firestore. HomeView menampilkan kategori dinamis. QuizController fetch soal dari Firestore.

### Kondisi Saat Ini (Yang Perlu Diubah)
```dart
// quiz_controller.dart — SEKARANG
quizSession = QuizData.getQuizByCategory(category); // hardcode

// home_view.dart — SEKARANG
// Kategori game hardcode:
_buildCategoryCard('Tarian Tradisional', 'assets/images/tarian_adat.png'),
_buildCategoryCard('Makanan Nusantara', 'assets/images/makanan_nusantara.png'),
// ... dst (semua hardcode)

// home_view.dart — reminder card SEKARANG
_buildReminderCard(title: 'Kuis 1', subtitle: 'Pakaian Adat...', progress: 9, ...) // hardcode
```

### File Baru yang Harus Dibuat

#### 1. `lib/shared/models/category_model.dart`
```dart
class CategoryModel {
  final String id;          // Firestore document ID
  final String name;        // "Tarian Tradisional"
  final String description;
  final String imagePath;   // "assets/images/tarian_adat.png"
  final int totalQuestions; // 15
  final bool isActive;
  final String createdBy;   // uid Admin
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // fromFirestore, toFirestore, copyWith
}
```

#### 2. `lib/shared/models/question_model.dart`
```dart
// Model ini menggantikan QuizQuestion di quiz_model.dart
class QuestionModel {
  final String id;            // Firestore document ID
  final String categoryId;    // ref ke categories
  final String categoryName;
  final String question;
  final List<String> options; // ["A. Aceh", "B. Bali", ...]
  final int correctIndex;
  final String? imageUrl;     // path assets atau null
  final bool isActive;

  // Helper getter
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // fromFirestore, toFirestore
}
```

#### 3. `lib/shared/services/quiz_service.dart`
```dart
class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil semua kategori yang isActive = true
  // Dipakai di HomeController untuk tampilkan grid kategori
  Future<List<CategoryModel>> getActiveCategories()

  // Ambil soal berdasarkan categoryId, hanya yang isActive = true
  // Di-shuffle agar urutan soal tidak selalu sama (opsional)
  Future<List<QuestionModel>> getQuestionsByCategoryId(String categoryId)

  // Ambil satu kategori berdasarkan nama
  // Dipakai QuizController saat user tap kategori dari HomeView
  Future<CategoryModel?> getCategoryByName(String name)
}
```

### File yang Harus Diupdate

#### `home_controller.dart` — Perubahan Kunci
```dart
// TAMBAHKAN state dan logika fetch kategori:
final isLoadingCategories = false.obs;
final categories = <CategoryModel>[].obs;
final lastActivity = Rxn<ProgressModel>(); // dari Fase 4

@override
void onInit() {
  super.onInit();
  fetchCategories();
}

Future<void> fetchCategories() async {
  // fetch dari Firestore via QuizService
  // set ke categories
}
```

#### `home_view.dart` — Perubahan Kunci
```dart
// _buildGameCategories() SESUDAH:
// Obx(() => ListView dari controller.categories)
// Bukan lagi hardcode

// _buildReminderCard() SESUDAH:
// Obx(() => data dari controller.userProgress)
// Bukan lagi hardcode

// Header nama user SESUDAH:
// Obx(() => Get.find<AuthController>().username)
// Bukan lagi 'Jhon Doe' hardcode
```

#### `quiz_controller.dart` — Perubahan Kunci
```dart
// onInit() SESUDAH:
// 1. Ambil category name dari Get.arguments
// 2. Fetch soal dari Firestore via QuizService
// 3. Set ke state (isLoading, questions, dsb)
// Bukan lagi: quizSession = QuizData.getQuizByCategory(category)
```

### Data Migrasi ke Firestore
```
Collection: categories (6 dokumen)
  ┌─────────────────────────────────────────────┐
  │ ID auto  │ name                    │ image   │
  ├─────────────────────────────────────────────┤
  │ auto     │ Tarian Tradisional      │ tarian  │
  │ auto     │ Pakaian Adat Nusantara  │ pakaian │
  │ auto     │ Rumah Adat Nusantara    │ rumah   │
  │ auto     │ Musik Tradisional ...   │ musik   │
  │ auto     │ Senjata Tradisional     │ senjata │
  │ auto     │ Makanan Nusantara       │ makanan │
  └─────────────────────────────────────────────┘

Collection: questions (90 dokumen)
  Semua soal dari quiz_data.dart dipindah ke sini
  Field correctAnswerIndex → correctIndex (rename)
```

### Checklist Fase 3
```
⬜ Buat lib/shared/models/category_model.dart
⬜ Buat lib/shared/models/question_model.dart
⬜ Buat lib/shared/services/quiz_service.dart
⬜ Input 6 kategori ke Firestore (manual via console/script)
⬜ Input 90 soal ke Firestore (via script Dart)
⬜ Update home_controller.dart (fetch kategori)
⬜ Update home_view.dart (kategori & username dinamis)
⬜ Update quiz_controller.dart (fetch soal dari Firestore)
⬜ Update quiz_model.dart (sesuaikan dengan QuestionModel baru)
⬜ Hapus quiz_data.dart setelah semua soal berhasil di Firestore
⬜ Test: kategori muncul di HomeView dari Firestore
⬜ Test: soal muncul di QuizView dari Firestore
```

---

## ⬜ FASE 4 — Simpan Hasil Quiz & Progress

### Tujuan
Setiap quiz selesai → simpan hasil ke Firestore → update poin user → update progress per kategori → HomeView reminder card jadi dinamis.

### File Baru yang Harus Dibuat

#### 1. `lib/shared/models/quiz_session_model.dart`
```dart
class QuizSessionModel {
  final String? id;             // Firestore document ID (null sebelum disimpan)
  final String userId;
  final String categoryId;
  final String categoryName;
  final int totalQuestions;     // 15
  final int correctAnswers;     // berapa yang benar
  final int wrongAnswers;       // totalQuestions - correctAnswers
  final int pointsEarned;       // poin yang didapat sesi ini
  final double percentage;      // (correctAnswers/totalQuestions) * 100
  final String grade;           // 'Sempurna!' | 'Sangat Baik!' | dll
  final int streak;             // streak saat sesi ini
  final bool isCompleted;       // true jika sampai soal terakhir
  final DateTime startedAt;
  final DateTime completedAt;
}
```

#### 2. `lib/shared/models/progress_model.dart`
```dart
class ProgressModel {
  final String categoryId;
  final String categoryName;
  final String imagePath;       // untuk tampilan di HomeView
  final int bestScore;          // persentase terbaik 0-100
  final int lastScore;          // persentase terakhir
  final int attempts;           // berapa kali main
  final int lastProgress;       // soal terakhir dijawab (misal: 9 dari 15)
  final int totalQuestions;     // 15
  final bool isCompleted;       // pernah selesai sampai soal terakhir
  final DateTime? lastPlayedAt;
}
```

#### 3. `lib/shared/services/quiz_result_service.dart`
```dart
class QuizResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan sesi quiz ke collection 'quiz_sessions'
  Future<void> saveQuizSession(QuizSessionModel session)

  // Update totalPoints di dokumen user (increment)
  Future<void> addPointsToUser(String uid, int pointsEarned)

  // Update stats soal (timesAnswered, timesWrong, wrongRate)
  // Dipanggil setelah setiap soal dijawab
  Future<void> updateQuestionStats(String questionId, bool isWrong)
}
```

#### 4. `lib/shared/services/progress_service.dart`
```dart
class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan atau update progress user untuk satu kategori
  // Path: user_progress/{uid}/categories/{categoryId}
  Future<void> saveProgress(String uid, String categoryId, ProgressModel progress)

  // Ambil semua progress user (untuk HomeView reminder cards)
  Future<List<ProgressModel>> getAllProgress(String uid)

  // Ambil satu progress untuk kategori tertentu
  Future<ProgressModel?> getProgress(String uid, String categoryId)

  // Ambil aktivitas terakhir (lastPlayedAt terbaru)
  Future<ProgressModel?> getLastActivity(String uid)
}
```

### File yang Harus Diupdate

#### `quiz_controller.dart` — Perubahan Kunci
```dart
// _showResultDialog() SESUDAH dialog ditampilkan:
// Sebelum dialog muncul, panggil:
// 1. QuizResultService.saveQuizSession(...)
// 2. QuizResultService.addPointsToUser(uid, pointsEarned)
// 3. ProgressService.saveProgress(uid, categoryId, ...)
// 4. LeaderboardService.updateLeaderboardEntry(uid, totalPoints)

// Tambahkan di quiz_controller:
final AuthController _authController = Get.find<AuthController>();
final QuizResultService _resultService = QuizResultService();
final ProgressService _progressService = ProgressService();
```

#### `home_controller.dart` — Perubahan Kunci
```dart
// Tambahkan fetch progress setelah fetch categories:
final userProgress = <ProgressModel>[].obs;
final lastActivity = Rxn<ProgressModel>();

Future<void> fetchUserProgress() async {
  final uid = Get.find<AuthController>().currentUser.value?.uid;
  if (uid == null) return;
  // fetch dari ProgressService
}
```

### Struktur Firestore: `quiz_sessions` & `user_progress`
```
quiz_sessions/
  {auto-id}/
    userId, categoryId, categoryName,
    totalQuestions, correctAnswers, wrongAnswers,
    pointsEarned, percentage, grade,
    streak, isCompleted, startedAt, completedAt

user_progress/
  {uid}/
    categories/           ← sub-collection
      {categoryId}/
        categoryId, categoryName, imagePath,
        bestScore, lastScore, attempts,
        lastProgress, totalQuestions,
        isCompleted, lastPlayedAt
```

### Checklist Fase 4
```
⬜ Buat lib/shared/models/quiz_session_model.dart
⬜ Buat lib/shared/models/progress_model.dart
⬜ Buat lib/shared/services/quiz_result_service.dart
⬜ Buat lib/shared/services/progress_service.dart
⬜ Update quiz_controller.dart (simpan hasil setelah quiz selesai)
⬜ Update home_controller.dart (load progress)
⬜ Update home_view.dart (reminder card & aktivitas terakhir dinamis)
⬜ Update home_view.dart (total poin dari AuthController)
⬜ Test: selesaikan quiz → cek quiz_sessions di Firestore
⬜ Test: poin user bertambah di Firestore
⬜ Test: progress muncul di HomeView reminder cards
```

---

## ⬜ FASE 5 — Leaderboard Real-time

### Tujuan
Leaderboard menampilkan data nyata dari Firestore secara real-time. Podium top 3 dan current user card menggunakan data asli.

### Kondisi Saat Ini (Yang Perlu Diubah)
```dart
// leaderboard_controller.dart — SEKARANG (hardcode)
final leaderboardData = <LeaderboardEntry>[
  LeaderboardEntry(rank: 1, username: 'keisya_pfp', score: 12500, ...),
  // ... semua hardcode
].obs;
```

### File Baru yang Harus Dibuat

#### 1. `lib/shared/models/leaderboard_model.dart`
```dart
class LeaderboardModel {
  final String uid;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int rank;           // dihitung dari posisi di list
  final DateTime? lastUpdated;

  // fromFirestore, toFirestore
}
```

#### 2. `lib/shared/services/leaderboard_service.dart`
```dart
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream real-time top 50 leaderboard
  // Query: orderBy('totalPoints', descending: true).limit(50)
  Stream<List<LeaderboardModel>> leaderboardStream()

  // Update atau create entry leaderboard untuk user
  // Dipanggil dari QuizResultService setelah quiz selesai
  Future<void> updateLeaderboardEntry(String uid, String username, int totalPoints)

  // Ambil rank user tertentu (posisi di leaderboard)
  Future<int> getUserRank(String uid)
}
```

### File yang Harus Diupdate

#### `leaderboard_controller.dart` — Perubahan Total
```dart
// HAPUS: leaderboardData hardcode
// GANTI dengan:

class LeaderboardController extends GetxController {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthController _authController = Get.find<AuthController>();

  final leaderboardData = <LeaderboardModel>[].obs;
  final isLoading = true.obs;

  // Stream subscription (harus di-cancel di onClose)
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenLeaderboard();
  }

  void _listenLeaderboard() {
    _subscription = _leaderboardService.leaderboardStream().listen((data) {
      leaderboardData.value = data;
      isLoading.value = false;
    });
  }

  // Getter: user yang sedang login
  LeaderboardModel? get currentUserEntry {
    final uid = _authController.currentUser.value?.uid;
    return leaderboardData.firstWhereOrNull((e) => e.uid == uid);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
```

#### `leaderboard_view.dart` — Perubahan Kunci
```dart
// _buildPodium() SESUDAH:
// Top 3 dari controller.leaderboardData (index 0,1,2)
// Bukan lagi hardcode username & score

// _buildLeaderboardList() SESUDAH:
// Obx(() => dari controller.leaderboardData)
// Sudah ada, tinggal ubah tipe data ke LeaderboardModel

// _buildCurrentUserCard() SESUDAH:
// controller.currentUserEntry (data nyata user login)
// Bukan lagi hardcode '3', 'Anda', '6370'
```

### Struktur Firestore: Collection `leaderboard`
```
leaderboard/
  {uid}/
    uid          : String
    username     : String
    avatarUrl    : String?  ← null jika belum ada foto profil
    totalPoints  : Number   ← diupdate setiap quiz selesai
    lastUpdated  : Timestamp
```

### Checklist Fase 5
```
⬜ Buat lib/shared/models/leaderboard_model.dart
⬜ Buat lib/shared/services/leaderboard_service.dart
⬜ Update leaderboard_controller.dart (stream dari Firestore)
⬜ Update leaderboard_view.dart (podium dari top 3)
⬜ Update leaderboard_view.dart (current user card nyata)
⬜ Test: selesaikan quiz → cek leaderboard update real-time
⬜ Test: podium menampilkan top 3 yang benar
⬜ Test: current user card menampilkan data login yang benar
```

---

## ⬜ FASE 6 — Profile & Settings

### Tujuan
ProfileView menampilkan data user nyata. Menu ganti nama/email/sandi berfungsi nyata. Settings toggle tersimpan ke Firestore.

### Kondisi Saat Ini (Yang Perlu Diubah)
```dart
// profile_view.dart — SEKARANG (semua hardcode)
const Text('Jhon Doe')          // ← ganti dengan AuthController.username
const Text('6370')              // ← ganti dengan AuthController.totalPoints
const Text('3')                 // ← ganti dengan AuthController.rank
const Text('87%')               // ← ganti dengan AuthController.correctRate

// settings_controller.dart — SEKARANG (tidak tersimpan)
final volumeSuara = true.obs;   // ← hilang saat app restart
```

### File Baru yang Harus Dibuat

#### 1. `lib/shared/models/settings_model.dart`
```dart
class SettingsModel {
  final bool volumeSuara;
  final bool deringPonsel;
  final bool notifikasi;

  // Default values, fromFirestore, toFirestore
}
```

#### 2. `lib/shared/services/user_service.dart`
```dart
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream data user real-time dari Firestore
  Stream<UserModel?> userStream(String uid)

  // Update username di Firestore
  Future<void> updateUsername(String uid, String newUsername)

  // Update email di Firebase Auth (butuh re-authenticate)
  Future<void> updateEmail(String newEmail, String currentPassword)

  // Update password di Firebase Auth (butuh re-authenticate)
  Future<void> updatePassword(String currentPassword, String newPassword)
}
```

#### 3. `lib/shared/services/settings_service.dart`
```dart
class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Path: users/{uid}/settings/preferences
  Future<void> saveSettings(String uid, SettingsModel settings)
  Future<SettingsModel> getSettings(String uid)
}
```

### File yang Harus Diupdate

#### `profile_controller.dart` — Perubahan Kunci
```dart
// Tambahkan:
final AuthController _authController = Get.find<AuthController>();

// Di ProfileView, akses data via:
// _authController.username
// _authController.totalPoints
// _authController.rank
// _authController.currentUser.value?.correctRate

// showFeatureSnackbar() — implementasi nyata:
void changeUsername() {
  // Tampilkan dialog input username baru
  // Panggil UserService.updateUsername()
  // Refresh AuthController
}

void changePassword() {
  // Tampilkan dialog input password lama + baru
  // Panggil UserService.updatePassword()
}
```

#### `settings_controller.dart` — Perubahan Kunci
```dart
// onInit() SESUDAH:
// Load settings dari Firestore via SettingsService

// toggleVolumeSuara() SESUDAH:
// Update nilai .obs
// Simpan ke Firestore via SettingsService
```

### Checklist Fase 6
```
⬜ Buat lib/shared/models/settings_model.dart
⬜ Buat lib/shared/services/user_service.dart
⬜ Buat lib/shared/services/settings_service.dart
⬜ Update profile_controller.dart (data nyata dari AuthController)
⬜ Update profile_view.dart (username, poin, rank, % dari controller)
⬜ Implementasi ganti nama (dialog + UserService)
⬜ Implementasi ganti sandi (dialog + UserService)
⬜ Update settings_controller.dart (load & simpan ke Firestore)
⬜ Test: nama user muncul di ProfileView sesuai yang login
⬜ Test: poin & rank sesuai data Firestore
⬜ Test: toggle settings tersimpan setelah app restart
```

---

## ⬜ FASE 7 — Security & Finishing

### Tujuan
Pasang Firestore Security Rules. Cleanup kode. Pastikan semua flow berjalan sempurna.

### main.dart — Update Final
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // HAPUS: print('Firebase connected: ${Firebase.app().name}');

  // Daftarkan AuthController sebagai GetxService
  await Get.putAsync(() async => AuthController());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
```

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isLoggedIn() {
      return request.auth != null;
    }
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
    function getRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    function isAdmin() {
      return getRole() == 'admin' || getRole() == 'superadmin';
    }
    function isSuperAdmin() {
      return getRole() == 'superadmin';
    }

    match /users/{uid} {
      allow read: if isLoggedIn() && (isOwner(uid) || isAdmin());
      allow create: if isLoggedIn() && isOwner(uid);
      allow update: if isLoggedIn() && isOwner(uid);
      allow delete: if isSuperAdmin();
      match /settings/{doc} {
        allow read, write: if isLoggedIn() && isOwner(uid);
      }
    }

    match /categories/{categoryId} {
      allow read: if isLoggedIn();
      allow create, update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    match /questions/{questionId} {
      allow read: if isLoggedIn();
      allow create, update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    match /quiz_sessions/{sessionId} {
      allow read: if isLoggedIn() && isOwner(resource.data.userId);
      allow create: if isLoggedIn();
      allow update, delete: if isSuperAdmin();
    }

    match /user_progress/{uid} {
      allow read, write: if isLoggedIn() && isOwner(uid);
      match /categories/{categoryId} {
        allow read, write: if isLoggedIn() && isOwner(uid);
        allow read: if isAdmin();
      }
    }

    match /leaderboard/{uid} {
      allow read: if isLoggedIn();
      allow write: if isLoggedIn() && isOwner(uid);
      allow delete: if isSuperAdmin();
    }

    match /admin_logs/{logId} {
      allow read, write: if isSuperAdmin();
    }
  }
}
```

### Checklist Fase 7
```
⬜ Update main.dart (hapus print, daftarkan AuthController)
⬜ Setup Firestore Security Rules di Firebase Console
⬜ Test Security Rules (pakai Firebase Rules Playground)
⬜ Hapus semua data hardcode yang sudah tidak dipakai
⬜ Hapus semua comment TODO yang sudah selesai
⬜ Test full flow: register → quiz → leaderboard → profile → logout
⬜ Test: user biasa tidak bisa akses data user lain
⬜ Test: splash redirect ke APP jika sudah login
⬜ Test: splash redirect ke SIGN_IN jika belum login
```

---

## 🗄️ RINGKASAN SEMUA COLLECTION FIRESTORE

```
santarana-quiz/
│
├── users/{uid}
│   ├── uid, username, email, role
│   ├── totalPoints, rank, correctRate
│   ├── quizCompleted, streak
│   ├── lastActiveAt, createdAt
│   └── settings/preferences/
│       └── volumeSuara, deringPonsel, notifikasi
│
├── categories/{categoryId}
│   ├── name, description, imagePath
│   ├── totalQuestions, isActive
│   └── createdBy, createdAt, updatedAt
│
├── questions/{questionId}
│   ├── categoryId, categoryName
│   ├── question, options[], correctIndex
│   ├── imageUrl, isActive
│   ├── createdBy, createdAt, updatedAt
│   └── stats/
│       └── timesAnswered, timesWrong, wrongRate
│
├── quiz_sessions/{sessionId}
│   ├── userId, categoryId, categoryName
│   ├── totalQuestions, correctAnswers, wrongAnswers
│   ├── pointsEarned, percentage, grade
│   └── streak, isCompleted, startedAt, completedAt
│
├── user_progress/{uid}
│   └── categories/{categoryId}
│       ├── categoryId, categoryName, imagePath
│       ├── bestScore, lastScore, attempts
│       ├── lastProgress, totalQuestions
│       └── isCompleted, lastPlayedAt
│
├── leaderboard/{uid}
│   ├── uid, username, avatarUrl
│   ├── totalPoints
│   └── lastUpdated
│
└── admin_logs/{logId}
    ├── adminId, action, targetId
    └── description, createdAt
```

---

## 🗂️ STRUKTUR FOLDER AKHIR SETELAH SEMUA FASE

```
lib/
├── main.dart                              ← UPDATE (Fase 7)
├── firebase_options.dart                  ← TIDAK DIUBAH
│
├── app/
│   ├── app_shell.dart                     ← TIDAK DIUBAH
│   ├── app_shell_binding.dart             ← TIDAK DIUBAH
│   ├── routes/
│   │   ├── app_pages.dart                 ← TIDAK DIUBAH
│   │   └── app_routes.dart                ← TIDAK DIUBAH
│   └── modules/
│       ├── splash/controllers/            ← UPDATE Fase 2
│       ├── sign_in/controllers/           ← UPDATE Fase 2
│       ├── register/controllers/          ← UPDATE Fase 2
│       ├── forgot_password/controllers/   ← UPDATE Fase 2
│       ├── email_verification/            ← TIDAK DIUBAH
│       ├── password_recovery_success/     ← TIDAK DIUBAH
│       ├── home/controllers/              ← UPDATE Fase 3 & 4
│       ├── home/views/                    ← UPDATE Fase 3 & 4
│       ├── quiz/controllers/              ← UPDATE Fase 3 & 4
│       ├── leaderboard/controllers/       ← UPDATE Fase 5
│       ├── leaderboard/views/             ← UPDATE Fase 5
│       ├── profile/controllers/           ← UPDATE Fase 2 & 6
│       ├── profile/views/                 ← UPDATE Fase 6
│       └── settings/controllers/          ← UPDATE Fase 6
│
└── shared/
    ├── controllers/
    │   └── auth_controller.dart           ← BARU Fase 2
    │
    ├── services/
    │   ├── auth_service.dart              ← BARU Fase 2
    │   ├── quiz_service.dart              ← BARU Fase 3
    │   ├── quiz_result_service.dart       ← BARU Fase 4
    │   ├── progress_service.dart          ← BARU Fase 4
    │   ├── leaderboard_service.dart       ← BARU Fase 5
    │   ├── user_service.dart              ← BARU Fase 6
    │   └── settings_service.dart          ← BARU Fase 6
    │
    ├── models/
    │   ├── user_model.dart                ← BARU Fase 2
    │   ├── category_model.dart            ← BARU Fase 3
    │   ├── question_model.dart            ← BARU Fase 3
    │   ├── quiz_session_model.dart        ← BARU Fase 4
    │   ├── progress_model.dart            ← BARU Fase 4
    │   ├── leaderboard_model.dart         ← BARU Fase 5
    │   └── settings_model.dart            ← BARU Fase 6
    │
    ├── data/
    │   ├── quiz_data.dart                 ← DIHAPUS Fase 3
    │   └── quiz_model.dart                ← UPDATE Fase 3
    │
    ├── theme/                             ← TIDAK DIUBAH SAMA SEKALI
    └── widgets/                           ← TIDAK DIUBAH SAMA SEKALI
```

---

## 🔑 ROLE PERMISSION TABLE

| Aksi | Super Admin | Admin | User |
|------|:-----------:|:-----:|:----:|
| CRUD Users | ✅ | ❌ | ❌ |
| Set Role User | ✅ | ❌ | ❌ |
| CRUD Categories | ✅ | ✅ | ❌ |
| CRUD Questions | ✅ | ✅ | ❌ |
| Lihat semua statistik | ✅ | Terbatas | Milik sendiri |
| Kelola Admin | ✅ | ❌ | ❌ |
| Main Quiz | ✅ | ✅ | ✅ |
| Lihat Leaderboard | ✅ | ✅ | ✅ |
| Edit Profil Sendiri | ✅ | ✅ | ✅ |
| Hapus Quiz Session | ✅ | ❌ | ❌ |
| Lihat Admin Logs | ✅ | ❌ | ❌ |

---

## 📋 CHECKLIST MASTER

```
FASE 1 ✅ — Setup Firebase
  ✅ Firebase project dibuat (santarana-quiz)
  ✅ Auth Email/Password diaktifkan
  ✅ Firestore dibuat (asia-southeast1)
  ✅ firebase_options.dart ter-generate
  ✅ Dependencies terpasang
  ✅ main.dart diupdate & koneksi berhasil

FASE 2 ⬜ — Auth & User
  ⬜ user_model.dart
  ⬜ auth_service.dart
  ⬜ auth_controller.dart (GetxService)
  ⬜ sign_in_controller.dart (update)
  ⬜ register_controller.dart (update)
  ⬜ forgot_password_controller.dart (update)
  ⬜ splash_controller.dart (update)
  ⬜ profile_controller.dart (update)

FASE 3 ⬜ — Quiz dari Firestore
  ⬜ category_model.dart
  ⬜ question_model.dart
  ⬜ quiz_service.dart
  ⬜ Migrate 6 kategori ke Firestore
  ⬜ Migrate 90 soal ke Firestore
  ⬜ home_controller.dart (update)
  ⬜ home_view.dart (update)
  ⬜ quiz_controller.dart (update)
  ⬜ Hapus quiz_data.dart

FASE 4 ⬜ — Hasil Quiz & Progress
  ⬜ quiz_session_model.dart
  ⬜ progress_model.dart
  ⬜ quiz_result_service.dart
  ⬜ progress_service.dart
  ⬜ quiz_controller.dart (simpan hasil)
  ⬜ home_controller.dart (load progress)
  ⬜ home_view.dart (reminder card dinamis)

FASE 5 ⬜ — Leaderboard Real-time
  ⬜ leaderboard_model.dart
  ⬜ leaderboard_service.dart
  ⬜ leaderboard_controller.dart (update)
  ⬜ leaderboard_view.dart (update)

FASE 6 ⬜ — Profile & Settings
  ⬜ settings_model.dart
  ⬜ user_service.dart
  ⬜ settings_service.dart
  ⬜ profile_controller.dart (update)
  ⬜ profile_view.dart (update)
  ⬜ settings_controller.dart (update)

FASE 7 ⬜ — Security & Finishing
  ⬜ main.dart (hapus debug, register AuthController)
  ⬜ Firestore Security Rules
  ⬜ Full testing semua flow
  ⬜ Cleanup semua data dummy & hardcode
```

---

> ⚠️ **PERHATIAN UNTUK AI:**
> - Kerjakan SATU fase sampai selesai sebelum lanjut ke fase berikutnya
> - Setiap file baru harus mengikuti pattern yang sudah ada di project
> - Jangan mengubah file theme/ dan widgets/ kecuali diminta eksplisit
> - Selalu gunakan `AppColors` untuk warna, bukan hardcode hex
> - Selalu gunakan widget `PrimaryButton`, `InputField` yang sudah ada
> - Package name: `package:santarana/...`
> - Project Firebase ID: `santarana-quiz`
