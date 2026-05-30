import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/modules/kategori_kuis/controllers/kategori_kuis_controller.dart';

class KategoriKuisView extends GetView<KategoriKuisController> {
  const KategoriKuisView({super.key});

  // ── Warna ────────────────────────────────────────────────────────────────
  static const _bg = Color(0xFFF9F4E4);
  static const _strokeDark = Color(0xFF3D1C10);
  static const _brownText = Color(0xFF714F4C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner Misi Eksplor Harian ─────────────────────────
              _buildMisionBanner(),
              const SizedBox(height: 24),

              // ── Grid misi ──────────────────────────────────────────
              _buildMissionGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _strokeDark,
          size: 20,
        ),
        onPressed: controller.goBack,
      ),
      title: Text(
        controller.categoryName,
        style: const TextStyle(
          color: _strokeDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── BANNER MISI EKSPLOR HARIAN ────────────────────────────────────────────
  Widget _buildMisionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _strokeDark.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _strokeDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/calender.png',
                width: 35,
                height: 35,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5A623),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFB85C52,
                          ).withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const Text(
                      'Misi Eksplor Harian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _strokeDark,
                        letterSpacing: 0.1,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB347).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Pengingat!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Selesaikan misi dan dapatkan medali:',
                style: TextStyle(
                  fontSize: 12,
                  color: _brownText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                'assets/images/badge_master.png',
                width: 26,
                height: 26,
                errorBuilder: (_, __, ___) =>
                    const Text('🏅', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── GRID MISI ─────────────────────────────────────────────────────────────
  Widget _buildMissionGrid() {
    return Obx(() {
      final missions = controller.missions;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: missions.length,
        itemBuilder: (_, i) => _buildMissionCard(missions[i]),
      );
    });
  }

  // ── SINGLE MISSION CARD ───────────────────────────────────────────────────
  // Mengikuti style card 1-6 di HomeView:
  // - Layer luar: border tebal (strokeDark), radius 20
  // - Layer dalam: gap 8px, border tipis, radius 14
  // - Angka besar dengan stroke
  // - Icon status dalam kotak border pojok kanan bawah
  Widget _buildMissionCard(KuisMission mission) {
    final isCompleted = mission.status == KuisMissionStatus.completed;
    final isInProgress = mission.status == KuisMissionStatus.inProgress;
    final isLocked = mission.status == KuisMissionStatus.locked;

    // Warna angka: emas untuk completed/inProgress, abu untuk locked
    final numberFillColor = (isCompleted || isInProgress)
        ? const Color(0xFFFFD700)
        : const Color(0xFFCCCCCC);

    // Opasitas border luar: penuh untuk aktif, redup untuk locked
    final outerBorderAlpha = isLocked ? 0.25 : 0.75;

    return GestureDetector(
      onTap: () => controller.onMissionTap(mission),
      child: Stack(
        children: [
          // ── Layer 1 (terluar): border tebal, background putih ──────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _strokeDark.withValues(alpha: outerBorderAlpha),
                width: 2.5,
              ),
            ),
          ),

          // ── Layer 2 (dalam): gap 8px dari tepi ─────────────────────
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _strokeDark.withValues(alpha: isLocked ? 0.20 : 0.60),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Angka dengan stroke (persis seperti HomeView) ──
                  Stack(
                    children: [
                      // Stroke layer
                      Text(
                        mission.number.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 36 * 0.08,
                          height: 1.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2.5
                            ..strokeJoin = StrokeJoin.round
                            ..color = const Color(0xFF383838),
                        ),
                      ),
                      // Fill layer
                      Text(
                        mission.number.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 36 * 0.08,
                          color: numberFillColor,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),

                  // ── Baris bawah: label difficulty + icon status ────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        mission.difficulty,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isLocked ? Colors.grey[400] : _brownText,
                        ),
                      ),
                      _buildBottomRightIcon(mission),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ICON POJOK KANAN BAWAH (dalam kotak border, seperti HomeView) ─────────
  Widget _buildBottomRightIcon(KuisMission mission) {
    final isLocked = mission.status == KuisMissionStatus.locked;

    // Warna border kotak: coklat untuk completed/inProgress, abu untuk locked
    final boxBorderColor = isLocked ? Colors.grey.shade500 : _strokeDark;

    Widget withBox(Widget child) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Kotak border
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: boxBorderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Icon sedikit overflow ke kanan bawah (seperti HomeView)
            Positioned(right: -5, bottom: 8, child: child),
          ],
        ),
      );
    }

    switch (mission.status) {
      case KuisMissionStatus.completed:
        return withBox(
          Image.asset(
            'assets/images/icon_check.png',
            width: 42,
            height: 42,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.check, size: 20, color: const Color(0xFF2E7D32)),
          ),
        );

      case KuisMissionStatus.inProgress:
        return withBox(
          Image.asset(
            'assets/images/icon_question.png',
            width: 42,
            height: 42,
            errorBuilder: (_, __, ___) => const Text(
              '?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFFCC3333),
              ),
            ),
          ),
        );

      case KuisMissionStatus.locked:
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
          child: Image.asset(
            'assets/images/icon_lock.png',
            width: 26,
            height: 26,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.lock_rounded, size: 22, color: Colors.grey[500]),
          ),
        );
    }
  }
}
