import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/services/profile_service.dart';

class EditProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  // ── Text Controllers ────────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Obscure toggles ─────────────────────────────────────────────────────────
  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  // ── Loading state ───────────────────────────────────────────────────────────
  final isLoading = false.obs;

  // ── Image picker ─────────────────────────────────────────────────────────────
  final _picker = ImagePicker();

  // ── AuthController reference ─────────────────────────────────────────────────
  AuthController get _auth => Get.find<AuthController>();

  // ── Toggle helpers ──────────────────────────────────────────────────────────
  void toggleOld() => obscureOld.value = !obscureOld.value;
  void toggleNew() => obscureNew.value = !obscureNew.value;
  void toggleConfirm() => obscureConfirm.value = !obscureConfirm.value;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill nama dari AuthController
    nameController.text = _auth.username;
  }

  // ── Pick foto dari galeri ──────────────────────────────────────────────────
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (picked == null) return;

      await _auth.updateLocalAvatar(picked.path);
      _showSnackbar('Berhasil', 'Foto profil berhasil diubah', isError: false);
    } catch (e) {
      _showSnackbar('Gagal', 'Tidak dapat membuka galeri', isError: true);
    }
  }

  // ── Validasi & Simpan ───────────────────────────────────────────────────────
  void onConfirm() {
    final name = nameController.text.trim();
    final oldPass = oldPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    // ── Validasi username ──────────────────────────────────────────────────
    if (name.isEmpty) {
      _showSnackbar('Gagal', 'Nama tidak boleh kosong', isError: true);
      return;
    }
    if (name.length < 3) {
      _showSnackbar('Peringatan', 'Nama minimal 3 karakter', isError: true);
      return;
    }

    // ── Cek apakah ada perubahan ───────────────────────────────────────────
    final isChangingUsername = name != _auth.username;
    final isChangingPassword =
        oldPass.isNotEmpty || newPass.isNotEmpty || confirmPass.isNotEmpty;

    if (!isChangingUsername && !isChangingPassword) {
      _showSnackbar(
        'Info',
        'Tidak ada perubahan yang disimpan',
        isError: false,
      );
      return;
    }

    // ── Validasi password jika diisi ───────────────────────────────────────
    if (isChangingPassword) {
      if (oldPass.isEmpty) {
        _showSnackbar('Peringatan', 'Password lama harus diisi', isError: true);
        return;
      }
      if (newPass.isEmpty) {
        _showSnackbar('Peringatan', 'Password baru harus diisi', isError: true);
        return;
      }
      if (newPass.length < 6) {
        _showSnackbar(
          'Peringatan',
          'Password baru minimal 6 karakter',
          isError: true,
        );
        return;
      }
      if (newPass != confirmPass) {
        _showSnackbar(
          'Gagal',
          'Konfirmasi password tidak cocok',
          isError: true,
        );
        return;
      }
      if (oldPass == newPass) {
        _showSnackbar(
          'Peringatan',
          'Password baru tidak boleh sama dengan password lama',
          isError: true,
        );
        return;
      }
    }

    _doSave(
      name: name,
      isChangingUsername: isChangingUsername,
      isChangingPassword: isChangingPassword,
      oldPassword: oldPass,
      newPassword: newPass,
    );
  }

  // ── Eksekusi Simpan ke Backend ─────────────────────────────────────────────
  Future<void> _doSave({
    required String name,
    required bool isChangingUsername,
    required bool isChangingPassword,
    required String oldPassword,
    required String newPassword,
  }) async {
    final uid = _auth.uid;
    if (uid == null) {
      _showSnackbar(
        'Error',
        'Sesi berakhir, silakan masuk ulang',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      // ── Jalankan update sesuai perubahan ───────────────────────────────
      final futures = <Future>[];

      if (isChangingUsername) {
        futures.add(
          _profileService.updateUsername(uid: uid, newUsername: name),
        );
      }

      if (isChangingPassword) {
        futures.add(
          _profileService.changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
          ),
        );
      }

      // Jalankan paralel jika keduanya berubah
      await Future.wait(futures);

      // ── Refresh AuthController agar semua halaman langsung update ──────
      await _auth.refreshUser();

      // ── Kembali ke ProfileView dulu, baru snackbar ─────────────────────
      Get.back();

      String successMsg = '';
      if (isChangingUsername && isChangingPassword) {
        successMsg = 'Username dan password berhasil diperbarui';
      } else if (isChangingUsername) {
        successMsg = 'Username berhasil diperbarui';
      } else {
        successMsg = 'Password berhasil diperbarui';
      }

      _showSnackbar('Berhasil', successMsg, isError: false);
    } on Exception catch (e) {
      // Tampilkan pesan error yang sudah di-map dari service
      final msg = e.toString().replaceAll('Exception: ', '');
      _showSnackbar('Gagal', msg, isError: true);
    } catch (_) {
      _showSnackbar('Error', 'Gagal menyimpan perubahan', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void onBatal() => Get.back();

  void _showSnackbar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
