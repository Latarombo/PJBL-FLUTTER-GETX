import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/settings/controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  static const _brown = Color(0xFF8B5A3C);
  static const _cream = Color(0xFFFFF8E7);
  static const _borderColor = Color(0xFFE8D5C4);
  static const _toggleActive = Color(0xFF8B5A3C);
  static const _toggleTrack = Color(0xFFE8B88A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      // extendBodyBehindAppBar agar konten bisa scroll bebas
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER (ikut scroll) ─────────────────────────────────────
            _buildHeader(context),

            // ── CONTENT ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Pengaturan Umum
                  _buildSectionLabel('Pengaturan Umum'),
                  const SizedBox(height: 12),

                  Obx(() => _buildToggleCard(
                        icon: Icons.music_note_rounded,
                        title: 'Music',
                        value: controller.music.value,
                        onChanged: controller.toggleMusic,
                      )),
                  const SizedBox(height: 10),

                  Obx(() => _buildToggleCard(
                        icon: Icons.volume_up_rounded,
                        title: 'Efek Suara',
                        value: controller.efekSuara.value,
                        onChanged: controller.toggleEfekSuara,
                      )),
                  const SizedBox(height: 10),

                  Obx(() => _buildToggleCard(
                        icon: Icons.vibration_outlined,
                        title: 'Getar Ponsel',
                        value: controller.getarPonsel.value,
                        onChanged: controller.toggleGetarPonsel,
                      )),
                  const SizedBox(height: 28),

                  // Section: Lainnya
                  _buildSectionLabel('Lainnya'),
                  const SizedBox(height: 12),

                  _buildNavCard(
                    icon: Icons.share_rounded,
                    title: 'Bagikan',
                    onTap: controller.onBagikan,
                  ),
                  const SizedBox(height: 10),

                  _buildNavCard(
                    icon: Icons.translate_rounded,
                    title: 'Ganti Bahasa',
                    onTap: controller.onGantiBahasa,
                  ),
                  const SizedBox(height: 10),

                  _buildNavCard(
                    icon: Icons.chat_outlined,
                    title: 'Kontak Kami',
                    onTap: controller.onKontakKami,
                  ),
                  const SizedBox(height: 10),

                  _buildNavCard(
                    icon: Icons.headset_mic_rounded,
                    title: 'Bantuan & Dukungan',
                    onTap: controller.onBantuanDukungan,
                  ),
                  const SizedBox(height: 10),

                  _buildNavCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Kami',
                    onTap: controller.onTentangKami,
                  ),
                  const SizedBox(height: 10),

                  _buildNavCard(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    onTap: controller.onLogOut,
                    iconColor: _brown,
                    titleColor: _brown,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER (scrollable, SafeArea di dalam) ──────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = (MediaQuery.of(context).size.height * 0)
        .clamp(180.0, 240.0);

    return Container(
      width: double.infinity,
      height: headerHeight + topPadding,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_profilePage.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.10),
              Colors.black.withValues(alpha: 0.38),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          children: [
            // ── Tombol "Bahasa Indonesia" pojok kanan atas ──────────────
            Positioned(
              top: 12,
              right: 16,
              child: _buildLanguageButton(),
            ),

            // ── Teks versi demo + Pengaturan di bawah ───────────────────
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'versi demo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LANGUAGE BUTTON ─────────────────────────────────────────────────────────
  Widget _buildLanguageButton() {
    return GestureDetector(
      onTap: () {}, // sambungkan ke onGantiBahasa jika perlu
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.translate_rounded,
              color: Colors.white,
              size: 15,
            ),
            SizedBox(width: 5),
            Text(
              'Bahasa Indonesia',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION LABEL ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _brown,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── TOGGLE CARD ─────────────────────────────────────────────────────────────
  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3D1C10), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3D1C10),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: _toggleActive,
              activeTrackColor: _toggleTrack,
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  // ── NAVIGATION CARD ─────────────────────────────────────────────────────────
  Widget _buildNavCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF3D1C10),
    Color titleColor = const Color(0xFF3D1C10),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[500],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}