# 🔄 FASE 2 — Auth & User
> Baca `AGENTS.md` (core) terlebih dahulu, lalu baca file ini.
> Status: **SEDANG DIKERJAKAN**
> Tujuan: Ganti semua auth dummy → Firebase Auth nyata + simpan user ke Firestore.

---

## 🎯 TUJUAN FASE INI

- Login & Register terhubung ke Firebase Auth
- Data user tersimpan di Firestore collection `users`
- `AuthController` (GetxService) menyimpan state user aktif
- Splash screen cek auth state → redirect yang benar
- Logout benar-benar keluar dari Firebase

---

## ❌ KONDISI SAAT INI (Yang Harus Diubah)

```dart
// sign_in_controller.dart — DUMMY, tidak ada Firebase
void handleSignIn() {
  Get.snackbar('Berhasil', 'Selamat datang...');
  Get.offAllNamed(Routes.APP); // langsung masuk tanpa auth
}

// register_controller.dart — DUMMY
void handleRegister() {
  Get.snackbar('Berhasil', 'Registrasi berhasil!');
  Get.offAllNamed(Routes.APP); // tidak simpan ke Firestore
}

// splash_controller.dart — tidak cek auth state
Future<void> _startFlow() async {
  Get.offAllNamed(Routes.SIGN_IN); // selalu ke sign in
}

// profile_controller.dart — logout dummy
void logout() {
  Get.offAllNamed(Routes.SIGN_IN); // tidak logout dari Firebase
}
```

---

## 📁 FILE BARU YANG HARUS DIBUAT

### 1. `lib/shared/models/user_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role; // 'user' | 'admin' | 'superadmin'
  final String? avatarUrl;
  final int totalPoints;
  final int rank;
  final double correctRate; // 0.0 - 100.0
  final int quizCompleted;
  final int streak;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.role = 'user',
    this.avatarUrl,
    this.totalPoints = 0,
    this.rank = 0,
    this.correctRate = 0.0,
    this.quizCompleted = 0,
    this.streak = 0,
    this.lastActiveAt,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      avatarUrl: data['avatarUrl'],
      totalPoints: data['totalPoints'] ?? 0,
      rank: data['rank'] ?? 0,
      correctRate: (data['correctRate'] ?? 0.0).toDouble(),
      quizCompleted: data['quizCompleted'] ?? 0,
      streak: data['streak'] ?? 0,
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'username': username,
    'email': email,
    'role': role,
    'avatarUrl': avatarUrl,
    'totalPoints': totalPoints,
    'rank': rank,
    'correctRate': correctRate,
    'quizCompleted': quizCompleted,
    'streak': streak,
    'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
  };

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    String? avatarUrl,
    int? totalPoints,
    int? rank,
    double? correctRate,
    int? quizCompleted,
    int? streak,
    DateTime? lastActiveAt,
    DateTime? createdAt,
  }) => UserModel(
    uid: uid ?? this.uid,
    username: username ?? this.username,
    email: email ?? this.email,
    role: role ?? this.role,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    totalPoints: totalPoints ?? this.totalPoints,
    rank: rank ?? this.rank,
    correctRate: correctRate ?? this.correctRate,
    quizCompleted: quizCompleted ?? this.quizCompleted,
    streak: streak ?? this.streak,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    createdAt: createdAt ?? this.createdAt,
  );
}
```

---

### 2. `lib/shared/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/user_model.dart';

// ⚠️ ATURAN SERVICE:
// - TIDAK ada navigasi Get.toNamed() di sini
// - TIDAK ada Get.snackbar() di sini
// - Lempar Exception jika gagal → Controller yang handle
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login — lempar Exception jika gagal
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      // Update lastActiveAt
      await _firestore.collection('users').doc(user.uid).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan, coba lagi');
    }
  }

  // Register — buat akun Auth + simpan ke Firestore, role default = 'user'
  Future<UserModel> register(String email, String username, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        username: username.trim(),
        email: email.trim(),
        role: 'user',
        totalPoints: 0,
        rank: 0,
        correctRate: 0.0,
        quizCompleted: 0,
        streak: 0,
        lastActiveAt: now,
        createdAt: now,
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan, coba lagi');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kirim email reset password
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  // Ambil data user dari Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil data user');
    }
  }

  // Mapping error code Firebase → Bahasa Indonesia
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'invalid-credential':
        return 'Email atau password salah';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}
```

---

### 3. `lib/shared/controllers/auth_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:santarana/shared/models/user_model.dart';
import 'package:santarana/shared/services/auth_service.dart';

// GetxService — didaftarkan SEKALI di main.dart
// Hidup sepanjang app — akses via Get.find<AuthController>()
class AuthController extends GetxService {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Getters shortcut — dipakai di View & Controller lain
  bool get isLoggedIn => currentUser.value != null;
  String get username => currentUser.value?.username ?? '';
  String get email => currentUser.value?.email ?? '';
  String get role => currentUser.value?.role ?? 'user';
  String? get avatarUrl => currentUser.value?.avatarUrl;
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';
  int get totalPoints => currentUser.value?.totalPoints ?? 0;
  int get rank => currentUser.value?.rank ?? 0;
  double get correctRate => currentUser.value?.correctRate ?? 0.0;
  int get quizCompleted => currentUser.value?.quizCompleted ?? 0;
  int get streak => currentUser.value?.streak ?? 0;
  String? get uid => currentUser.value?.uid;

  // Set user setelah login / register
  void setUser(UserModel user) {
    currentUser.value = user;
  }

  // Clear user setelah logout
  void clearUser() {
    currentUser.value = null;
  }

  // Refresh data user dari Firestore (setelah update poin, dsb)
  Future<void> refreshUser() async {
    final uid = currentUser.value?.uid;
    if (uid == null) return;
    final updated = await _authService.getUserData(uid);
    if (updated != null) currentUser.value = updated;
  }
}
```

---

## 📝 FILE YANG HARUS DIUPDATE

### `main.dart` — Daftarkan AuthController

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // print('Firebase connected...'); ← BIARKAN dulu, hapus di Fase 7

  // ✅ BARU: Daftarkan AuthController sebagai GetxService global
  await Get.putAsync(() async => AuthController());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
```

---

### `splash_controller.dart` — Cek Auth State

```dart
// Tambahkan import:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/services/auth_service.dart';

// Ubah _startFlow():
Future<void> _startFlow() async {
  // Animasi splash tetap jalan dulu
  await fadeController.forward();
  await Future.delayed(const Duration(milliseconds: 800));
  await slideController.forward();
  await Future.delayed(const Duration(milliseconds: 2800));

  // ✅ BARU: Cek auth state
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    // Load data user ke AuthController
    final authController = Get.find<AuthController>();
    final userData = await AuthService().getUserData(firebaseUser.uid);
    if (userData != null) {
      authController.setUser(userData);
    }
    Get.offAllNamed(Routes.APP);
  } else {
    Get.offAllNamed(Routes.SIGN_IN);
  }
}
```

---

### `sign_in_controller.dart` — Auth Nyata

```dart
// Tambahkan imports & dependencies:
final AuthService _authService = AuthService();
final isLoading = false.obs; // ← BARU

// ⚠️ KEPUTUSAN DESAIN:
// Field di View saat ini hint: 'Username'
// Firebase Auth butuh email untuk login
// → REKOMENDASI: ganti hint menjadi 'Email' (lebih simpel)
// → ATAU: rename field label saja, value tetap dikirim sebagai email

// Ubah handleSignIn():
Future<void> handleSignIn() async {
  // Validasi (tetap ada)
  if (emailController.text.isEmpty) {
    Get.snackbar('Gagal', 'Email tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    return;
  }
  if (passwordController.text.isEmpty) {
    Get.snackbar('Gagal', 'Password tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  try {
    isLoading.value = true;
    final user = await _authService.signIn(
      emailController.text,
      passwordController.text,
    );
    Get.find<AuthController>().setUser(user);
    Get.offAllNamed(Routes.APP);
  } catch (e) {
    Get.snackbar('Gagal Masuk', e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
```

---

### `register_controller.dart` — Simpan ke Firestore

```dart
// Tambahkan:
final AuthService _authService = AuthService();
final isLoading = false.obs;

// Ubah handleRegister():
Future<void> handleRegister() async {
  // Validasi (tetap ada — email, username, password, konfirmasi)
  if (emailController.text.isEmpty || usernameController.text.isEmpty ||
      passwordController.text.isEmpty) {
    Get.snackbar('Gagal', 'Semua field harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    return;
  }
  if (passwordController.text != confirmPasswordController.text) {
    Get.snackbar('Gagal', 'Password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  try {
    isLoading.value = true;
    final user = await _authService.register(
      emailController.text,
      usernameController.text,
      passwordController.text,
    );
    Get.find<AuthController>().setUser(user);
    Get.offAllNamed(Routes.APP);
  } catch (e) {
    Get.snackbar('Registrasi Gagal', e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
```

---

### `forgot_password_controller.dart` — Email Reset Nyata

```dart
// Tambahkan:
final AuthService _authService = AuthService();
final isLoading = false.obs;

// Ubah validEmailSubmit() atau fungsi submit yang ada:
Future<void> handleSubmit() async {
  if (emailController.text.isEmpty) {
    Get.snackbar('Gagal', 'Email tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  try {
    isLoading.value = true;
    await _authService.sendPasswordReset(emailController.text);
    // Firebase kirim email reset otomatis
    // Navigasi ke halaman sukses atau tampilkan snackbar
    Get.snackbar('Email Terkirim',
        'Cek inbox email Anda untuk reset password',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    // Opsi: langsung kembali ke sign_in
    // Get.offAllNamed(Routes.SIGN_IN);
    // Opsi: navigasi ke password_recovery_success
    // Get.toNamed(Routes.PASSWORD_RECOVERY_SUCCESS);
  } catch (e) {
    Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
```

---

### `profile_controller.dart` — Logout Nyata

```dart
// Tambahkan:
final AuthService _authService = AuthService();
final AuthController _authController = Get.find<AuthController>();

// Ubah logout():
Future<void> logout() async {
  // Dialog konfirmasi (jika sudah ada, tetap pakai)
  // Setelah konfirmasi:
  try {
    await _authService.signOut();
    _authController.clearUser();
    Get.offAllNamed(Routes.SIGN_IN);
  } catch (e) {
    Get.snackbar('Error', 'Gagal logout, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }
}
```

---

## 🗄️ STRUKTUR FIRESTORE: Collection `users`

```
users/
  {uid}/
    uid            : String       ← sama dengan Firebase Auth UID
    username       : String       ← "Najwa_Miniww"
    email          : String       ← "najwa@email.com"
    role           : String       ← "user" (default saat register)
    avatarUrl      : String?      ← null (belum ada fitur upload)
    totalPoints    : Number       ← 0
    rank           : Number       ← 0
    correctRate    : Number       ← 0.0
    quizCompleted  : Number       ← 0
    streak         : Number       ← 0
    lastActiveAt   : Timestamp    ← diupdate saat login
    createdAt      : Timestamp    ← saat register
```

---

## 🔐 ERROR MESSAGES FIREBASE → BAHASA INDONESIA

```
'user-not-found'         → 'Email tidak terdaftar'
'wrong-password'         → 'Password salah'
'invalid-credential'     → 'Email atau password salah'
'email-already-in-use'   → 'Email sudah terdaftar'
'weak-password'          → 'Password terlalu lemah (min. 6 karakter)'
'invalid-email'          → 'Format email tidak valid'
'network-request-failed' → 'Tidak ada koneksi internet'
'too-many-requests'      → 'Terlalu banyak percobaan, coba lagi nanti'
default                  → 'Terjadi kesalahan, coba lagi'
```

---

## ✅ CHECKLIST FASE 2

```
✅ Buat lib/shared/models/user_model.dart
✅ Buat lib/shared/services/auth_service.dart
✅ Buat lib/shared/controllers/auth_controller.dart
⬜ Daftarkan AuthController di main.dart (Get.putAsync)
⬜ Update splash_controller.dart (cek auth state)
⬜ Update sign_in_controller.dart (Firebase Auth + isLoading)
⬜ Update register_controller.dart (register + simpan Firestore)
⬜ Update forgot_password_controller.dart (sendPasswordReset)
⬜ Update profile_controller.dart (logout nyata)
⬜ Test: register user baru → cek di Firebase Console > Firestore > users
⬜ Test: login dengan akun yang baru dibuat → masuk ke APP
⬜ Test: restart app → splash langsung ke APP (sudah login)
⬜ Test: logout → kembali ke sign_in
⬜ Test: login email salah → snackbar error muncul
⬜ Test: forgot password → email masuk di inbox
```
