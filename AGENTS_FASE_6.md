# ⬜ FASE 6 — Profile & Settings
> Baca `AGENTS.md` (core) terlebih dahulu, lalu baca file ini.
> Status: **STANDBY** — kerjakan setelah Fase 5 selesai & ter-checklist semua.
> Tujuan: ProfileView data nyata, ganti nama/sandi berfungsi, settings tersimpan ke Firestore.

---

## 🎯 TUJUAN FASE INI

- ProfileView menampilkan username, poin, rank, % benar dari data nyata
- Ganti nama & ganti password berfungsi nyata via Firebase
- Toggle settings (volume, dering, notifikasi) tersimpan ke Firestore
- Settings tetap ada setelah app restart

---

## ❌ KONDISI SAAT INI (Yang Harus Diubah)

```dart
// profile_view.dart — semua hardcode
const Text('Jhon Doe')   // ← ganti dengan AuthController.username
const Text('6370')        // ← ganti dengan AuthController.totalPoints
const Text('3')           // ← ganti dengan AuthController.rank
const Text('87%')         // ← ganti dengan AuthController.correctRate

// profile_controller.dart — fitur tidak berfungsi
void changeUsername() => Get.snackbar('Info', 'Fitur segera hadir');
void changePassword() => Get.snackbar('Info', 'Fitur segera hadir');

// settings_controller.dart — tidak tersimpan
final volumeSuara = true.obs;    // hilang saat app restart
final deringPonsel = true.obs;
final notifikasi = true.obs;
```

---

## 📁 FILE BARU YANG HARUS DIBUAT

### 1. `lib/shared/models/settings_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final bool volumeSuara;
  final bool deringPonsel;
  final bool notifikasi;

  const SettingsModel({
    this.volumeSuara = true,
    this.deringPonsel = true,
    this.notifikasi = true,
  });

  // Default settings untuk user baru
  factory SettingsModel.defaults() => const SettingsModel();

  factory SettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SettingsModel(
      volumeSuara: data['volumeSuara'] ?? true,
      deringPonsel: data['deringPonsel'] ?? true,
      notifikasi: data['notifikasi'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'volumeSuara': volumeSuara,
    'deringPonsel': deringPonsel,
    'notifikasi': notifikasi,
  };

  SettingsModel copyWith({
    bool? volumeSuara,
    bool? deringPonsel,
    bool? notifikasi,
  }) => SettingsModel(
    volumeSuara: volumeSuara ?? this.volumeSuara,
    deringPonsel: deringPonsel ?? this.deringPonsel,
    notifikasi: notifikasi ?? this.notifikasi,
  );
}
```

---

### 2. `lib/shared/services/user_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/user_model.dart';

// ⚠️ Service rules: tidak ada navigasi, tidak ada snackbar
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream data user real-time — untuk profile yang selalu update
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Update username di Firestore
  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      if (newUsername.trim().isEmpty) throw Exception('Username tidak boleh kosong');
      await _firestore.collection('users').doc(uid).update({
        'username': newUsername.trim(),
      });
    } catch (e) {
      throw Exception('Gagal mengubah username: $e');
    }
  }

  // Update email — butuh re-authenticate dulu
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Tidak ada user yang login');

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email di Auth
      await user.verifyBeforeUpdateEmail(newEmail.trim());

      // Update email di Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail.trim(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') throw Exception('Password salah');
      if (e.code == 'email-already-in-use') throw Exception('Email sudah digunakan');
      throw Exception('Gagal mengubah email: ${e.message}');
    }
  }

  // Update password — butuh re-authenticate dulu
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Tidak ada user yang login');

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') throw Exception('Password lama salah');
      if (e.code == 'weak-password') throw Exception('Password baru terlalu lemah');
      throw Exception('Gagal mengubah password: ${e.message}');
    }
  }
}
```

---

### 3. `lib/shared/services/settings_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/settings_model.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Path: users/{uid}/settings/preferences
  Future<void> saveSettings(String uid, SettingsModel settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('preferences')
          .set(settings.toFirestore());
    } catch (e) {
      throw Exception('Gagal menyimpan settings: $e');
    }
  }

  Future<SettingsModel> getSettings(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('preferences')
          .get();
      if (!doc.exists) return SettingsModel.defaults();
      return SettingsModel.fromFirestore(doc);
    } catch (e) {
      return SettingsModel.defaults(); // fallback ke default jika gagal
    }
  }
}
```

---

## 📝 FILE YANG HARUS DIUPDATE

### `profile_controller.dart` — Data Nyata + Fitur Berfungsi

```dart
// Tambahkan:
final AuthController _authController = Get.find<AuthController>();
final UserService _userService = UserService();
final isLoading = false.obs;

// Data dari AuthController — otomatis reaktif via Obx di View
// _authController.username
// _authController.totalPoints
// _authController.rank
// _authController.correctRate
// _authController.quizCompleted

// Implementasi changeUsername():
Future<void> changeUsername() async {
  // Tampilkan dialog input username baru
  final TextEditingController inputCtrl = TextEditingController();
  Get.defaultDialog(
    title: 'Ganti Nama',
    content: InputField(controller: inputCtrl, hint: 'Username baru'),
    textConfirm: 'Simpan',
    textCancel: 'Batal',
    onConfirm: () async {
      try {
        isLoading.value = true;
        Get.back(); // tutup dialog
        await _userService.updateUsername(
          _authController.uid!,
          inputCtrl.text,
        );
        await _authController.refreshUser();
        Get.snackbar('Berhasil', 'Username berhasil diubah',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
      }
    },
  );
}

// Implementasi changePassword():
Future<void> changePassword() async {
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  Get.defaultDialog(
    title: 'Ganti Password',
    content: Column(children: [
      InputField(controller: currentPassCtrl, hint: 'Password lama'),
      const SizedBox(height: 8),
      InputField(controller: newPassCtrl, hint: 'Password baru'),
    ]),
    textConfirm: 'Simpan',
    textCancel: 'Batal',
    onConfirm: () async {
      try {
        isLoading.value = true;
        Get.back();
        await _userService.updatePassword(
          currentPassCtrl.text,
          newPassCtrl.text,
        );
        Get.snackbar('Berhasil', 'Password berhasil diubah',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
      }
    },
  );
}
```

---

### `profile_view.dart` — Tampilkan Data Nyata

```dart
// UBAH semua hardcode:

// Nama user
Obx(() => Text(
  Get.find<AuthController>().username,
  style: TextStyle(/* style yang sudah ada */),
))

// Total poin
Obx(() => Text(
  Get.find<AuthController>().totalPoints.toString(),
))

// Rank
Obx(() => Text(
  Get.find<AuthController>().rank.toString(),
))

// Persentase benar
Obx(() => Text(
  '${Get.find<AuthController>().correctRate.toStringAsFixed(0)}%',
))
```

---

### `settings_controller.dart` — Load & Simpan ke Firestore

```dart
// Tambahkan:
final SettingsService _settingsService = SettingsService();
final AuthController _authController = Get.find<AuthController>();

// Ubah onInit() — load dari Firestore:
@override
void onInit() {
  super.onInit();
  _loadSettings();
}

Future<void> _loadSettings() async {
  final uid = _authController.uid;
  if (uid == null) return;
  final settings = await _settingsService.getSettings(uid);
  volumeSuara.value = settings.volumeSuara;
  deringPonsel.value = settings.deringPonsel;
  notifikasi.value = settings.notifikasi;
}

// Ubah setiap toggle — simpan ke Firestore:
void toggleVolumeSuara() {
  volumeSuara.value = !volumeSuara.value;
  _saveSettings();
}

void toggleDeringPonsel() {
  deringPonsel.value = !deringPonsel.value;
  _saveSettings();
}

void toggleNotifikasi() {
  notifikasi.value = !notifikasi.value;
  _saveSettings();
}

Future<void> _saveSettings() async {
  final uid = _authController.uid;
  if (uid == null) return;
  await _settingsService.saveSettings(uid, SettingsModel(
    volumeSuara: volumeSuara.value,
    deringPonsel: deringPonsel.value,
    notifikasi: notifikasi.value,
  ));
}
```

---

## 🗄️ STRUKTUR FIRESTORE FASE 6

```
users/{uid}/settings/preferences
  volumeSuara   : Boolean  ← true/false
  deringPonsel  : Boolean
  notifikasi    : Boolean
```

---

## ✅ CHECKLIST FASE 6

```
⬜ Buat lib/shared/models/settings_model.dart
⬜ Buat lib/shared/services/user_service.dart
⬜ Buat lib/shared/services/settings_service.dart
⬜ Update profile_controller.dart (AuthController data + changeUsername + changePassword)
⬜ Update profile_view.dart (username, poin, rank, % dari controller/AuthController)
⬜ Update settings_controller.dart (load & simpan settings ke Firestore)
⬜ Test: nama user muncul di ProfileView sesuai yang login
⬜ Test: poin & rank sesuai data Firestore
⬜ Test: ganti username → tersimpan & langsung update di view
⬜ Test: ganti password dengan password lama salah → error muncul
⬜ Test: ganti password berhasil → bisa login dengan password baru
⬜ Test: toggle settings → restart app → settings tetap sama
```
