import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:santarana/shared/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Gagal masuk, coba lagi');
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      await userRef.update({'lastActiveAt': FieldValue.serverTimestamp()});

      final doc = await userRef.get();
      if (!doc.exists) {
        throw Exception('Data user tidak ditemukan');
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } on Exception catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Terjadi kesalahan, coba lagi');
    } catch (_) {
      throw Exception('Terjadi kesalahan, coba lagi');
    }
  }

  Future<UserModel> register(
    String email,
    String username,
    String password,
  ) async {
    try {
      final trimmedEmail = email.trim();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Gagal membuat akun, coba lagi');
      }

      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        username: username.trim(),
        email: trimmedEmail,
        role: 'user',
        totalPoints: 0,
        rank: 0,
        correctRate: 0.0,
        quizCompleted: 0,
        streak: 0,
        lastActiveAt: now,
        createdAt: now,
      );

      // Simpan user + leaderboard entry paralel
      await Future.wait([
        _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore()),

        // ── Langsung masuk leaderboard dengan poin 0 ──────────────────
        _firestore.collection('leaderboard').doc(user.uid).set({
          'uid': user.uid,
          'username': username.trim(),
          'avatarUrl': null,
          'totalPoints': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        }),
      ]);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } on Exception catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Terjadi kesalahan, coba lagi');
    } catch (_) {
      throw Exception('Terjadi kesalahan, coba lagi');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (_) {
      throw Exception('Gagal keluar, coba lagi');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login Google dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('Gagal login dengan Google');

      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        // User baru — buat dokumen
        final now = DateTime.now();
        final username =
            user.displayName ?? user.email?.split('@').first ?? 'User';

        final userModel = UserModel(
          uid: user.uid,
          username: username,
          email: user.email ?? '',
          role: 'user',
          avatarUrl: user.photoURL,
          totalPoints: 0,
          rank: 0,
          correctRate: 0.0,
          quizCompleted: 0,
          streak: 0,
          lastActiveAt: now,
          createdAt: now,
        );

        await Future.wait([
          userRef.set(userModel.toFirestore()),
          _firestore.collection('leaderboard').doc(user.uid).set({
            'uid': user.uid,
            'username': username,
            'avatarUrl': user.photoURL,
            'totalPoints': 0,
            'lastUpdated': FieldValue.serverTimestamp(),
          }),
        ]);

        return userModel;
      } else {
        // User lama — update lastActiveAt
        await userRef.update({'lastActiveAt': FieldValue.serverTimestamp()});
        return UserModel.fromFirestore(doc);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } on Exception catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Gagal login dengan Google');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (_) {
      await _auth.signOut();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (_) {
      throw Exception('Gagal mengirim email reset password');
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (_) {
      throw Exception('Gagal mengambil data user');
    }
  }

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
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan';
      case 'requires-recent-login':
        return 'Silakan masuk ulang untuk melanjutkan';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Anda tidak memiliki izin untuk mengakses data ini';
      case 'unavailable':
        return 'Layanan sedang tidak tersedia, coba lagi nanti';
      case 'not-found':
        return 'Data tidak ditemukan';
      case 'deadline-exceeded':
        return 'Koneksi terlalu lama, coba lagi';
      case 'cancelled':
        return 'Permintaan dibatalkan';
      case 'resource-exhausted':
        return 'Terlalu banyak permintaan, coba lagi nanti';
      case 'unauthenticated':
        return 'Sesi berakhir, silakan masuk ulang';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}
