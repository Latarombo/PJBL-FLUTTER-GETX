# ⬜ FASE 7 — Security & Finishing
> Baca `AGENTS.md` (core) terlebih dahulu, lalu baca file ini.
> Status: **STANDBY** — kerjakan setelah Fase 6 selesai & ter-checklist semua.
> Tujuan: Pasang Firestore Security Rules. Cleanup kode. Full testing semua flow.

---

## 🎯 TUJUAN FASE INI

- Firestore Security Rules aktif — user tidak bisa akses data orang lain
- `print()` debug dihapus dari seluruh project
- Semua data dummy & hardcode dibersihkan
- Semua flow berjalan sempurna end-to-end
- App siap production

---

## 📝 FILE YANG HARUS DIUPDATE

### `main.dart` — Final Clean Version

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ✅ HAPUS baris ini:
  // print('Firebase connected: ${Firebase.app().name}');

  // AuthController sudah didaftarkan di Fase 2 — pastikan masih ada:
  await Get.putAsync(() async => AuthController());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
```

---

## 🔐 FIRESTORE SECURITY RULES

> Pasang di Firebase Console → Firestore → Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
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

    // Collection: users
    match /users/{uid} {
      allow read: if isLoggedIn() && (isOwner(uid) || isAdmin());
      allow create: if isLoggedIn() && isOwner(uid);
      allow update: if isLoggedIn() && isOwner(uid);
      allow delete: if isSuperAdmin();

      match /settings/{doc} {
        allow read, write: if isLoggedIn() && isOwner(uid);
      }
    }

    // Collection: categories
    match /categories/{categoryId} {
      allow read: if isLoggedIn();
      allow create, update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Collection: questions
    match /questions/{questionId} {
      allow read: if isLoggedIn();
      allow create, update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Collection: quiz_sessions
    match /quiz_sessions/{sessionId} {
      allow read: if isLoggedIn() && isOwner(resource.data.userId);
      allow create: if isLoggedIn();
      allow update, delete: if isSuperAdmin();
    }

    // Collection: user_progress
    match /user_progress/{uid} {
      allow read, write: if isLoggedIn() && isOwner(uid);

      match /categories/{categoryId} {
        allow read, write: if isLoggedIn() && isOwner(uid);
        allow read: if isAdmin();
      }
    }

    // Collection: leaderboard
    match /leaderboard/{uid} {
      allow read: if isLoggedIn();
      allow write: if isLoggedIn() && isOwner(uid);
      allow delete: if isSuperAdmin();
    }

    // Collection: admin_logs
    match /admin_logs/{logId} {
      allow read, write: if isSuperAdmin();
    }
  }
}
```

---

## 🧹 CLEANUP YANG HARUS DILAKUKAN

### Hapus dari Kode

```
⬜ Hapus semua print() di seluruh project (cari dengan: grep -r "print(" lib/)
⬜ Hapus semua comment TODO yang sudah selesai
⬜ Hapus quiz_data.dart (sudah dimigasi di Fase 3)
⬜ Pastikan quiz_model.dart tidak lagi referensi ke quiz_data.dart
⬜ Hapus semua data hardcode yang sudah tidak dipakai
⬜ Hapus import yang tidak dipakai di seluruh file
```

### Verifikasi Pattern

```
⬜ Tidak ada setState() di manapun
⬜ Tidak ada StatefulWidget di manapun (kecuali jika ada alasan khusus)
⬜ Tidak ada BuildContext untuk navigasi
⬜ Semua warna pakai AppColors (bukan hardcode hex)
⬜ Semua tombol pakai PrimaryButton (bukan ElevatedButton biasa)
⬜ Semua input pakai InputField (bukan TextField biasa)
⬜ Semua snackbar pakai Get.snackbar (bukan ScaffoldMessenger)
```

---

## 🧪 FULL TESTING CHECKLIST

### Auth Flow

```
⬜ Register user baru → cek di Firebase Console > Authentication
⬜ Register user baru → cek dokumen di Firestore > users
⬜ Register dengan email yang sudah ada → error muncul
⬜ Login dengan akun baru → masuk ke APP
⬜ Login dengan password salah → error muncul
⬜ Restart app → splash langsung ke APP (sudah login)
⬜ Restart app tanpa login → splash ke SIGN_IN
⬜ Forgot password → email terkirim di inbox
⬜ Logout → kembali ke SIGN_IN
⬜ Restart setelah logout → tetap di SIGN_IN
```

### Quiz Flow

```
⬜ Buka HomeView → kategori muncul dari Firestore
⬜ Tap kategori → masuk QuizView, soal muncul dari Firestore
⬜ Jawab semua soal → result dialog muncul
⬜ Selesai quiz → poin bertambah di Firestore
⬜ Selesai quiz → quiz_sessions tersimpan di Firestore
⬜ Selesai quiz → progress tersimpan di user_progress
⬜ Buka HomeView → reminder card menampilkan quiz terakhir
```

### Leaderboard Flow

```
⬜ Selesai quiz → leaderboard collection terupdate
⬜ Buka LeaderboardView → data nyata muncul
⬜ Podium menampilkan top 3 yang benar
⬜ Current user card menampilkan rank & poin yang benar
⬜ Buka di 2 device → update satu device → device lain update real-time
```

### Profile & Settings Flow

```
⬜ Buka ProfileView → nama, poin, rank, % benar semua data nyata
⬜ Ganti username → tersimpan & tampil di ProfileView
⬜ Ganti password → bisa login dengan password baru
⬜ Toggle settings → restart app → settings tetap sama
```

### Security

```
⬜ Test Security Rules di Firebase Rules Playground
⬜ User A tidak bisa baca data users/uid_B (harus gagal)
⬜ User biasa tidak bisa create/update categories (harus gagal)
⬜ User yang belum login tidak bisa akses data apapun (harus gagal)
```

---

## 🗂️ STRUKTUR FOLDER AKHIR (Referensi)

```
lib/
├── main.dart                              ← CLEAN (no print, AuthController registered)
├── firebase_options.dart                  ← TIDAK DIUBAH
│
├── app/
│   ├── app_shell.dart                     ← TIDAK DIUBAH
│   ├── app_shell_binding.dart             ← TIDAK DIUBAH
│   ├── routes/
│   │   ├── app_pages.dart                 ← TIDAK DIUBAH
│   │   └── app_routes.dart                ← TIDAK DIUBAH
│   └── modules/
│       ├── splash/controllers/            ← UPDATED Fase 2
│       ├── sign_in/controllers/           ← UPDATED Fase 2
│       ├── register/controllers/          ← UPDATED Fase 2
│       ├── forgot_password/controllers/   ← UPDATED Fase 2
│       ├── home/controllers/              ← UPDATED Fase 3 & 4
│       ├── home/views/                    ← UPDATED Fase 3 & 4
│       ├── quiz/controllers/              ← UPDATED Fase 3 & 4
│       ├── leaderboard/controllers/       ← UPDATED Fase 5
│       ├── leaderboard/views/             ← UPDATED Fase 5
│       ├── profile/controllers/           ← UPDATED Fase 2 & 6
│       ├── profile/views/                 ← UPDATED Fase 6
│       └── settings/controllers/          ← UPDATED Fase 6
│
└── shared/
    ├── controllers/
    │   └── auth_controller.dart           ← BARU Fase 2
    ├── services/
    │   ├── auth_service.dart              ← BARU Fase 2
    │   ├── quiz_service.dart              ← BARU Fase 3
    │   ├── quiz_result_service.dart       ← BARU Fase 4
    │   ├── progress_service.dart          ← BARU Fase 4
    │   ├── leaderboard_service.dart       ← BARU Fase 5
    │   ├── user_service.dart              ← BARU Fase 6
    │   └── settings_service.dart          ← BARU Fase 6
    ├── models/
    │   ├── user_model.dart                ← BARU Fase 2
    │   ├── category_model.dart            ← BARU Fase 3
    │   ├── question_model.dart            ← BARU Fase 3
    │   ├── quiz_session_model.dart        ← BARU Fase 4
    │   ├── progress_model.dart            ← BARU Fase 4
    │   ├── leaderboard_model.dart         ← BARU Fase 5
    │   └── settings_model.dart            ← BARU Fase 6
    ├── data/
    │   ├── quiz_data.dart                 ← DIHAPUS Fase 3
    │   └── quiz_model.dart                ← UPDATED Fase 3
    ├── theme/                             ← TIDAK DIUBAH
    └── widgets/                           ← TIDAK DIUBAH
```

---

## ✅ CHECKLIST FASE 7

```
⬜ Update main.dart (hapus print, pastikan AuthController terdaftar)
⬜ Setup Firestore Security Rules di Firebase Console
⬜ Test Security Rules via Firebase Rules Playground
⬜ Hapus semua print() dari seluruh project
⬜ Hapus semua comment TODO yang sudah selesai
⬜ Hapus semua data hardcode yang sudah tidak dipakai
⬜ Verifikasi tidak ada setState/StatefulWidget/BuildContext navigasi
⬜ Full testing: register → quiz → leaderboard → profile → logout
⬜ Security test: user tidak bisa akses data user lain
⬜ Security test: user tidak login tidak bisa akses Firestore
⬜ Final: build release & pastikan tidak ada error
```
