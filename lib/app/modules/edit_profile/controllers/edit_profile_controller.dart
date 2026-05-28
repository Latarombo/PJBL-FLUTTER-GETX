import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';

class EditProfileController extends GetxController {
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

  // ── Toggle helpers ──────────────────────────────────────────────────────────
  void toggleOld() => obscureOld.value = !obscureOld.value;
  void toggleNew() => obscureNew.value = !obscureNew.value;
  void toggleConfirm() => obscureConfirm.value = !obscureConfirm.value;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill nama dari AuthController
    nameController.text = Get.find<AuthController>().username;
    if (nameController.text.isEmpty) {
      nameController.text = 'Najwa_Miniww'; // dummy fallback
    }
  }

  // ── Pick foto dari galeri ──────────────────────────────────────────────────
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // kompres sedikit agar tidak terlalu besar
        maxWidth: 512,
        maxHeight: 512,
      );

      if (picked == null) return; // user batal memilih

      // Simpan path ke AuthController — semua halaman langsung update
      await Get.find<AuthController>().updateLocalAvatar(picked.path);

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

    if (name.isEmpty) {
      _showSnackbar('Gagal', 'Nama tidak boleh kosong', isError: true);
      return;
    }
    if (name.length < 3) {
      _showSnackbar('Peringatan', 'Nama minimal 3 karakter', isError: true);
      return;
    }

    final isChangingPassword =
        oldPass.isNotEmpty || newPass.isNotEmpty || confirmPass.isNotEmpty;

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

    _doSave(name, isChangingPassword);
  }

  Future<void> _doSave(String name, bool isChangingPassword) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: ganti dengan pemanggilan service nyata
      // await _authService.updateProfile(name, newPassword);

      // Kembali ke ProfileView dulu, baru snackbar
      Get.back();

      _showSnackbar(
        'Berhasil',
        isChangingPassword
            ? 'Profil dan password berhasil diperbarui'
            : 'Nama berhasil diperbarui',
        isError: false,
      );
    } catch (e) {
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
