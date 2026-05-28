import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5EFE6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF3D1C10), size: 20),
            onPressed: controller.onBatal,
          ),
          title: const Text(
            'Informasi pribadi',
            style: TextStyle(
              color: Color(0xFF3D1C10),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // ── Card Utama ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar ───────────────────────────────────────────
                      Center(child: _buildAvatar()),
                      const SizedBox(height: 28),

                      // ── Section: Edit Akun ───────────────────────────────
                      const Text(
                        'Edit Akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D1C10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nama
                      _buildLabel('Nama'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: controller.nameController,
                        hint: 'Masukkan nama',
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),

                      // ── Section: Ganti Password ──────────────────────────
                      const Text(
                        'Ganti Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D1C10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password Lama
                      _buildLabel('Password lama'),
                      const SizedBox(height: 6),
                      Obx(() => _buildPasswordField(
                            controller: controller.oldPasswordController,
                            hint: '••••••••',
                            obscure: controller.obscureOld.value,
                            onToggle: controller.toggleOld,
                          )),
                      const SizedBox(height: 14),

                      // Password Baru
                      _buildLabel('Password baru'),
                      const SizedBox(height: 6),
                      Obx(() => _buildPasswordField(
                            controller: controller.newPasswordController,
                            hint: '••••••••',
                            obscure: controller.obscureNew.value,
                            onToggle: controller.toggleNew,
                          )),
                      const SizedBox(height: 14),

                      // Konfirmasi Password
                      _buildLabel('Konfirmasi password'),
                      const SizedBox(height: 6),
                      Obx(() => _buildPasswordField(
                            controller: controller.confirmPasswordController,
                            hint: '••••••••',
                            obscure: controller.obscureConfirm.value,
                            onToggle: controller.toggleConfirm,
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action Buttons ─────────────────────────────────────────
                Obx(() => _buildActionButtons(controller.isLoading.value)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AVATAR ────────────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    return Stack(
      children: [
        // Foto profil
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/user.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFFFC4D6),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF8B4789),
                  size: 48,
                ),
              ),
            ),
          ),
        ),

        // Tombol edit foto — pojok kanan bawah
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              // TODO: image picker
              Get.snackbar(
                'Info',
                'Fitur ganti foto akan segera hadir',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF7A2828),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── LABEL ─────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B4C3B),
      ),
    );
  }

  // ── TEXT FIELD ────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF3D1C10),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9F4EE),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF8B3A3A), width: 1.8),
        ),
      ),
    );
  }

  // ── PASSWORD FIELD ────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF3D1C10),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9F4EE),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF8B3A3A), width: 1.8),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[400],
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  // ── ACTION BUTTONS ────────────────────────────────────────────────────────
  Widget _buildActionButtons(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Batal
        TextButton(
          onPressed: isLoading ? null : controller.onBatal,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B3A3A),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Batal'),
        ),
        const SizedBox(width: 12),

        // Konfirmasi
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : controller.onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A2828),
              disabledBackgroundColor: const Color(0xFF7A2828).withOpacity(0.5),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Konfirmasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}