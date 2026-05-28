import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/shared/widgets/user_avatar.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  static const _bg = Color(0xFFF9F4E4);
  static const _cardBg = Colors.white;
  static const _titleColor = Color(0xFF3D1C10);
  static const _labelColor = Color(0xFF6B4C3B);
  static const _accentRed = Color(0xFF7A2828);
  static const _fieldBg = Color(0xFFF9F4EE);
  static const _borderIdle = Color(0xFFE8DDD5);
  static const _borderFocus = Color(0xFF8B3A3A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: _buildMainCard(),
          ),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _titleColor,
          size: 20,
        ),
        onPressed: controller.onBatal,
      ),
      title: const Text(
        'Informasi pribadi',
        style: TextStyle(
          color: _titleColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── MAIN CARD ─────────────────────────────────────────────────────────────
  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D1C10).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + tombol edit foto ────────────────────────────────
          Center(child: _buildAvatarWithEditButton()),
          const SizedBox(height: 28),

          // ── Section: Edit Akun ───────────────────────────────────────
          _buildSectionTitle('Edit Akun'),
          const SizedBox(height: 14),
          _buildLabel('Nama'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: controller.nameController,
            hint: 'Masukkan nama',
          ),
          const SizedBox(height: 24),

          // ── Divider ──────────────────────────────────────────────────
          Container(height: 1, color: const Color(0xFFF0E8DF)),
          const SizedBox(height: 22),

          // ── Section: Ganti Password ──────────────────────────────────
          _buildSectionTitle('Ganti Password'),
          const SizedBox(height: 14),

          _buildLabel('Password'),
          const SizedBox(height: 6),
          Obx(
            () => _buildPasswordField(
              ctrl: controller.oldPasswordController,
              hint: '••••••••',
              obscure: controller.obscureOld.value,
              onToggle: controller.toggleOld,
            ),
          ),
          const SizedBox(height: 14),

          _buildLabel('Password baru'),
          const SizedBox(height: 6),
          Obx(
            () => _buildPasswordField(
              ctrl: controller.newPasswordController,
              hint: '••••••••',
              obscure: controller.obscureNew.value,
              onToggle: controller.toggleNew,
            ),
          ),
          const SizedBox(height: 14),

          _buildLabel('Konfirmasi password'),
          const SizedBox(height: 6),
          Obx(
            () => _buildPasswordField(
              ctrl: controller.confirmPasswordController,
              hint: '••••••••',
              obscure: controller.obscureConfirm.value,
              onToggle: controller.toggleConfirm,
            ),
          ),

          const SizedBox(height: 28),

          // ── Action Buttons ────────────────────────────────────────────
          Obx(() => _buildActionButtons(controller.isLoading.value)),
        ],
      ),
    );
  }

  // ── AVATAR + TOMBOL EDIT FOTO ─────────────────────────────────────────────
  Widget _buildAvatarWithEditButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── UserAvatar reaktif (dari shared widget) ──────────────────
        UserAvatar(size: 96, borderWidth: 3, borderColor: Colors.white),

        // ── Tombol edit foto — pojok kanan bawah ─────────────────────
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.pickImageFromGallery,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
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

  // ── SECTION TITLE ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: _titleColor,
        letterSpacing: 0.1,
      ),
    );
  }

  // ── LABEL ─────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _labelColor,
      ),
    );
  }

  // ── TEXT FIELD ────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        color: _titleColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBCAFA7), fontSize: 14),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderIdle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderIdle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderFocus, width: 1.8),
        ),
      ),
    );
  }

  // ── PASSWORD FIELD ────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(
        fontSize: 14,
        color: _titleColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBCAFA7), fontSize: 14),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderIdle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderIdle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderFocus, width: 1.8),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFFBCAFA7),
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
        TextButton(
          onPressed: isLoading ? null : controller.onBatal,
          style: TextButton.styleFrom(
            foregroundColor: _accentRed,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Batal'),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: isLoading ? null : controller.onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentRed,
              disabledBackgroundColor: _accentRed.withOpacity(0.45),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              minimumSize: Size.zero,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
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
