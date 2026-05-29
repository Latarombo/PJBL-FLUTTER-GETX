import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:santarana/shared/models/user_model.dart';

/// ProfileService
/// ─────────────────────────────────────────────────
/// Bertanggung jawab atas:
/// 1. Update username (Firestore users + leaderboard)
/// 2. Ganti password (re-auth dulu, baru updatePassword)
/// 3. Hitung rank user berdasarkan posisi di leaderboard
///
/// Rules: tidak ada navigasi, tidak ada Get.snackbar.
/// Lempar Exception jika gagal — biarkan Controller yang handle.
class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── 1. UPDATE USERNAME ───────────────────────────────────────────────────

  /// Update username di:
  ///   • collection users/{uid}
  ///   • collection leaderboard/{uid} (jika entry ada)
  ///
  /// Dijalankan paralel dengan Future.wait untuk efisiensi.
  Future<void> updateUsername({
    required String uid,
    required String newUsername,
  }) async {
    final trimmed = newUsername.trim();

    if (trimmed.isEmpty) {
      throw Exception('Username tidak boleh kosong');
    }
    if (trimmed.length < 3) {
      throw Exception('Username minimal 3 karakter');
    }

    try {
      // Cek duplikat username (opsional — skip jika sama dengan username lama)
      final existing = await _firestore
          .collection('users')
          .where('username', isEqualTo: trimmed)
          .limit(1)
          .get();

      // Jika ada user lain dengan username yang sama, tolak
      if (existing.docs.isNotEmpty && existing.docs.first.id != uid) {
        throw Exception('Username "$trimmed" sudah digunakan');
      }

      // Update paralel: users + leaderboard
      await Future.wait([
        _firestore.collection('users').doc(uid).update({
          'username': trimmed,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        // Leaderboard: gunakan set+merge agar tidak error jika belum ada
        _firestore.collection('leaderboard').doc(uid).set({
          'username': trimmed,
        }, SetOptions(merge: true)),
      ]);
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Gagal mengubah username');
    }
  }

  // ─── 2. GANTI PASSWORD (RE-AUTH FLOW) ────────────────────────────────────

  /// Urutan:
  ///   1. Re-authenticate dengan email + oldPassword
  ///   2. Jika berhasil → updatePassword ke newPassword
  ///
  /// Melempar Exception dengan pesan yang user-friendly.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi berakhir, silakan masuk ulang');
    if (user.email == null) throw Exception('Email tidak ditemukan');

    if (newPassword.length < 6) {
      throw Exception('Password baru minimal 6 karakter');
    }
    if (oldPassword == newPassword) {
      throw Exception('Password baru tidak boleh sama dengan password lama');
    }

    try {
      // Step 1: Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Step 2: Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Gagal mengubah password');
    }
  }

  // ─── 3. HITUNG RANK DARI LEADERBOARD ─────────────────────────────────────

  /// Ambil posisi user di leaderboard berdasarkan totalPoints.
  /// Rank = jumlah user yang punya poin LEBIH TINGGI + 1.
  ///
  /// Efisien: hanya COUNT query, tidak fetch semua dokumen.
  /// Firestore tidak support COUNT langsung di semua SDK,
  /// maka kita pakai pendekatan: ambil leaderboard terurut,
  /// cari index uid user.
  Future<int> getRankFromLeaderboard(String uid) async {
    try {
      // Ambil semua entri terurut descending (max 500 untuk performa)
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('totalPoints', descending: true)
          .limit(500)
          .get();

      final index = snapshot.docs.indexWhere((doc) => doc.id == uid);

      // Jika tidak ditemukan di leaderboard → rank 0 (belum bermain)
      if (index == -1) return 0;

      return index + 1; // rank dimulai dari 1
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (_) {
      return 0; // non-critical: kembalikan 0 jika gagal
    }
  }

  // ─── 4. UPDATE RANK DI FIRESTORE USER ────────────────────────────────────

  /// Simpan rank terbaru ke users/{uid}.rank
  /// Dipanggil setelah getRankFromLeaderboard.
  Future<void> saveRank({required String uid, required int rank}) async {
    try {
      await _firestore.collection('users').doc(uid).update({'rank': rank});
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (_) {
      // Non-critical — jangan crash
    }
  }

  // ─── 5. STREAM STATS REAL-TIME ────────────────────────────────────────────

  /// Stream dokumen user dari Firestore.
  /// ProfileController subscribe ke stream ini agar stats selalu up-to-date.
  Stream<UserModel> userStatsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => UserModel.fromFirestore(snap));
  }

  // ─── ERROR MAPPING ────────────────────────────────────────────────────────

  String _mapAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Password lama salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'requires-recent-login':
        return 'Silakan masuk ulang untuk melanjutkan';
      case 'weak-password':
        return 'Password baru terlalu lemah (min. 6 karakter)';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Gagal mengubah password, coba lagi';
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Tidak memiliki izin';
      case 'unavailable':
        return 'Layanan tidak tersedia, coba lagi nanti';
      case 'not-found':
        return 'Data tidak ditemukan';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}
