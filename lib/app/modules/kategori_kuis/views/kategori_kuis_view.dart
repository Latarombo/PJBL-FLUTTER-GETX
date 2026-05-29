import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/modules/kategori_kuis/controllers/kategori_kuis_controller.dart';

class KategoriKuisView extends GetView<KategoriKuisController> {
  const KategoriKuisView({super.key});

  // ── Warna ────────────────────────────────────────────────────────────────
  static const _bg         = Color(0xFFF9F4E4);
  static const _strokeDark = Color(0xFF3D1C10);
  static const _gold       = Color(0xFFB8860B);
  static const _grey       = Color(0xFFCCCCCC);
  static const _brownText  = Color(0xFF714F4C);
  static const _redDark    = Color(0xFF8B3A3A);

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
          // ── Baris atas: ikon kalender + judul + label "Pengingat!" ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon kalender dari asset
              Image.asset(
                'assets/images/logo_mascot2.png',
                width: 36,
                height: 36,
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

              // Judul dengan underline merah
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
                          color: const Color(0xFFB85C52).withValues(alpha: 0.50),
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

              // Label "Pengingat!" di kanan atas
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
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

          // ── Baris bawah: sub-teks + ikon medali ────────────────────
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
  Widget _buildMissionCard(KuisMission mission) {
    final isCompleted  = mission.status == KuisMissionStatus.completed;
    final isInProgress = mission.status == KuisMissionStatus.inProgress;
    final isLocked     = mission.status == KuisMissionStatus.locked;

    // Warna angka: emas untuk completed/inProgress, abu untuk locked
    final numberColor = (isCompleted || isInProgress) ? _gold : _grey;

    return GestureDetector(
      onTap: () => controller.onMissionTap(mission),
      child: Stack(
        children: [
          // ── Layer 1 (terluar): border tebal, radius besar ──────────
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _strokeDark.withValues(alpha: isLocked ? 0.25 : 0.75),
                width: 2.5,
              ),
            ),
          ),

          // ── Layer 2 (dalam): card putih dengan gap 8px ──────────────
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
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Baris atas: nomor saja (tanpa icon api) ────────
                  Text(
                    mission.number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 36 * 0.08,
                      color: numberColor,
                      height: 1.0,
                    ),
                  ),

                  // ── Baris bawah: label kesulitan + icon status ─────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        mission.difficulty,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isLocked
                              ? Colors.grey[400]
                              : _brownText,
                        ),
                      ),
                      _buildStatusIcon(mission),
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

  // ── ICON STATUS (pojok kanan bawah) ──────────────────────────────────────
  // completed  → icon_check.png
  // inProgress → icon_question.png
  // locked     → icon_lock.png
  Widget _buildStatusIcon(KuisMission mission) {
    switch (mission.status) {
      case KuisMissionStatus.completed:
        return Image.asset(
          'assets/images/icon_check.png',
          width: 30,
          height: 30,
          errorBuilder: (_, __, ___) => Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF2E7D32),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
        );

      case KuisMissionStatus.inProgress:
        return Image.asset(
          'assets/images/icon_question.png',
          width: 30,
          height: 30,
          errorBuilder: (_, __, ___) => const Text(
            '?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFFCC3333),
            ),
          ),
        );

      case KuisMissionStatus.locked:
        return Image.asset(
          'assets/images/icon_lock.png',
          width: 26,
          height: 26,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.lock_rounded, size: 22, color: Colors.grey[500]),
        );
    }
  }
}