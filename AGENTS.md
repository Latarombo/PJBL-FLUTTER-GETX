# 🏛️ SantaraNa — AGENTS.md (Core)
> Baca file ini SETIAP SESI sebelum menulis kode.
> Firebase + Flutter + GetX | Project ID: `santarana-quiz` | Package: `package:santarana/...`
> Dart `^3.10.7` | Flutter terbaru

---

## 📂 FILE AGENTS YANG ADA

```
AGENTS.md              ← File ini — aturan & konvensi GLOBAL (selalu berlaku)
AGENTS_FASE_2.md       ← 🔄 AKTIF — Auth & User (Firebase Auth + Firestore)
AGENTS_FASE_3.md       ← ⬜ Standby — Quiz dari Firestore
AGENTS_FASE_4.md       ← ⬜ Standby — Hasil Quiz & Progress
AGENTS_FASE_5.md       ← ⬜ Standby — Leaderboard Real-time
AGENTS_FASE_6.md       ← ⬜ Standby — Profile & Settings
AGENTS_FASE_7.md       ← ⬜ Standby — Security & Finishing
```

> ⚠️ Saat mengerjakan suatu fase, baca `AGENTS.md` (ini) + `AGENTS_FASE_X.md` yang aktif.
> File fase lain TIDAK perlu dibaca kecuali diminta.

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

## 🚨 ATURAN WAJIB — JANGAN DILANGGAR

```
1.  SELALU gunakan GetX untuk state management — DILARANG pakai setState/StatefulWidget
2.  SELALU gunakan GetView<Controller> untuk semua halaman
3.  SELALU gunakan Get.snackbar() untuk notifikasi — BUKAN ScaffoldMessenger
4.  SELALU gunakan Get.toNamed() / Get.offAllNamed() untuk navigasi
5.  SELALU pisahkan logika ke Controller & Service — View hanya UI
6.  DILARANG menulis logika bisnis di dalam View/Widget
7.  DILARANG menggunakan BuildContext untuk navigasi
8.  SELALU buat loading state dengan .obs di Controller
9.  SELALU handle error dengan try-catch di Service layer
10. JANGAN ubah file theme/, widgets/, atau route yang tidak diminta
```

---

## 📦 STACK & DEPENDENCIES

```yaml
# pubspec.yaml (Dependencies Aktif)
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
```

### Import Pattern

```dart
// Untuk file BARU — gunakan wildcard (lebih simpel)
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/...';

// Jika ada konflik, gunakan import spesifik:
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
```

---

## 🏗️ ARSITEKTUR & STRUKTUR FOLDER

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── app_shell.dart                     ← JANGAN DIUBAH
│   ├── app_shell_binding.dart             ← JANGAN DIUBAH
│   ├── routes/
│   │   ├── app_pages.dart                 ← JANGAN DIUBAH
│   │   └── app_routes.dart                ← JANGAN DIUBAH
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
    ├── controllers/                       ← GetxService global
    ├── services/                          ← Firebase logic
    ├── models/                            ← Data models
    ├── data/
    │   ├── quiz_data.dart                 ← DIHAPUS di Fase 3
    │   └── quiz_model.dart
    ├── theme/                             ← JANGAN DIUBAH SAMA SEKALI
    └── widgets/                           ← JANGAN DIUBAH SAMA SEKALI
```

### Routes yang Sudah Ada

```dart
static const SPLASH                  = '/';
static const SIGN_IN                 = '/sign-in';
static const REGISTER                = '/register';
static const FORGOT_PASSWORD         = '/forgot-password';
static const EMAIL_VERIFICATION      = '/email-verification';
static const PASSWORD_RECOVERY_SUCCESS = '/password-recovery-success';
static const APP                     = '/app';
static const HOME                    = '/home';
static const QUIZ                    = '/quiz';
static const LEADERBOARD             = '/leaderboard';
static const PROFILE                 = '/profile';
static const SETTINGS                = '/settings';
```

---

## 🎨 DESIGN SYSTEM (JANGAN DIUBAH)

### Warna — gunakan `AppColors`, BUKAN hardcode hex

```dart
AppColors.background    // Color(0xFFF9F4E4) — cream, background semua halaman
AppColors.backgroundAlt // Color(0xFFFFF8E7) — cream alt
AppColors.dark          // Color(0xFF1A2332) — primary button
AppColors.accent        // Color(0xFFFFB347) — orange, progress bar
AppColors.textPrimary   // Color(0xff270f0f) — teks utama
AppColors.navBar        // Color(0xFFFFDDB3) — bottom nav
AppColors.navBarActive  // Color(0xFFE8B88A) — nav active
AppColors.navBarIcon    // Color(0xFF8B5A3C) — nav icon
```

### Widget Siap Pakai — gunakan ini, JANGAN buat baru

```dart
PrimaryButton(text: 'Masuk', onPressed: () {})
InputField(controller: ctrl, hint: 'Email')
SocialLoginButton(text: '...', iconPath: '...', onPressed: () {})
OtpInput(length: 4, onCompleted: (otp) {})
```

### Snackbar — SELALU pakai pola ini

```dart
// ✅ Success
Get.snackbar('Berhasil', 'Pesan sukses',
    backgroundColor: Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM);

// ❌ Error
Get.snackbar('Error', 'Pesan error',
    backgroundColor: Colors.red,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM);

// ⚠️ Warning
Get.snackbar('Peringatan', 'Pesan warning',
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM);
```

---

## 🔑 ROLE PERMISSION TABLE

| Aksi                   | Super Admin | Admin    | User         |
|------------------------|:-----------:|:--------:|:------------:|
| CRUD Users             | ✅          | ❌       | ❌           |
| Set Role User          | ✅          | ❌       | ❌           |
| CRUD Categories        | ✅          | ✅       | ❌           |
| CRUD Questions         | ✅          | ✅       | ❌           |
| Lihat semua statistik  | ✅          | Terbatas | Milik sendiri|
| Kelola Admin           | ✅          | ❌       | ❌           |
| Main Quiz              | ✅          | ✅       | ✅           |
| Lihat Leaderboard      | ✅          | ✅       | ✅           |
| Edit Profil Sendiri    | ✅          | ✅       | ✅           |
| Hapus Quiz Session     | ✅          | ❌       | ❌           |
| Lihat Admin Logs       | ✅          | ❌       | ❌           |

---

## 📐 POLA KODE STANDAR

### Controller

```dart
class XxxController extends GetxController {
  // 1. Dependencies
  final SomeService _service = SomeService();

  // 2. Reactive state — semua pakai .obs
  final isLoading = false.obs;
  final someData = <Model>[].obs;

  // 3. Lifecycle
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // 4. Methods — logika di sini, navigasi di sini, BUKAN di View
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      // ...
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
```

### View

```dart
class XxxView extends GetView<XxxController> {
  const XxxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) return const CircularProgressIndicator();
        return Column(children: [ /* UI only, no logic */ ]);
      }),
    );
  }
}
```

### Binding

```dart
class XxxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XxxController>(() => XxxController());
  }
}
```

### Service

```dart
class XxxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TIDAK ada navigasi di sini
  // TIDAK ada Get.snackbar di sini
  // Lempar Exception jika gagal — biarkan Controller yang handle
  Future<Model> getData() async {
    try {
      // Firebase call
    } catch (e) {
      throw Exception('Pesan error: $e');
    }
  }
}
```

---

## 🗄️ RINGKASAN COLLECTIONS FIRESTORE

```
santarana-quiz/
├── users/{uid}
│   ├── uid, username, email, role ('user'|'admin'|'superadmin')
│   ├── totalPoints, rank, correctRate, quizCompleted, streak
│   ├── avatarUrl, lastActiveAt, createdAt
│   └── settings/preferences/
│       └── volumeSuara, deringPonsel, notifikasi
├── categories/{categoryId}
│   └── name, description, imagePath, totalQuestions, isActive, createdBy, createdAt, updatedAt
├── questions/{questionId}
│   ├── categoryId, categoryName, question, options[], correctIndex
│   ├── imageUrl, isActive, createdBy, createdAt, updatedAt
│   └── stats/ → timesAnswered, timesWrong, wrongRate
├── quiz_sessions/{sessionId}
│   └── userId, categoryId, categoryName, totalQuestions, correctAnswers,
│       wrongAnswers, pointsEarned, percentage, grade, streak, isCompleted,
│       startedAt, completedAt
├── user_progress/{uid}/categories/{categoryId}
│   └── categoryId, categoryName, imagePath, bestScore, lastScore,
│       attempts, lastProgress, totalQuestions, isCompleted, lastPlayedAt
├── leaderboard/{uid}
│   └── uid, username, avatarUrl, totalPoints, lastUpdated
└── admin_logs/{logId}
    └── adminId, action, targetId, description, createdAt
```
