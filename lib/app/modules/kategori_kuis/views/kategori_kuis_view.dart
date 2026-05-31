import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/modules/kategori_kuis/controllers/kategori_kuis_controller.dart';
import 'package:santarana/shared/models/category_progress_model.dart';

class KategoriKuisView extends GetView<KategoriKuisController> {
  const KategoriKuisView({super.key});

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
              _buildMisionBanner(),
              const SizedBox(height: 24),
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

  // ── BANNER ────────────────────────────────────────────────────────────────
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
                    Icons.quiz_rounded,
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
                      'Level Quiz',
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
                  'Selesaikan!',
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
          // Legend status
          Row(
            children: [
              _buildLegendItem(
                Icons.lock_rounded,
                Colors.grey.shade400,
                'Terkunci',
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                Icons.help_rounded,
                const Color(0xFFCC3333),
                'Tersedia',
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                Icons.check_circle_rounded,
                const Color(0xFF2E7D32),
                'Selesai',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── GRID MISI ─────────────────────────────────────────────────────────────
  Widget _buildMissionGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFFFFB347)),
          ),
        );
      }

      final cards = controller.cards;
      if (cards.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Belum ada data. Coba lagi nanti.',
              style: TextStyle(color: _brownText),
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: cards.length,
        itemBuilder: (_, i) => _buildMissionCard(cards[i]),
      );
    });
  }

  // ── SINGLE MISSION CARD ───────────────────────────────────────────────────
  Widget _buildMissionCard(CardWithStatus card) {
    // FIX: replay diperlakukan sama seperti completed secara visual
    final isCompleted =
        card.status == CardStatus.completed ||
        card.status == CardStatus.replay;
    final isAvailable = card.status == CardStatus.available;
    final isLocked = card.status == CardStatus.locked;

    final numberFillColor = isCompleted
        ? const Color(0xFFFFD700) // emas jika selesai / replay
        : isAvailable
        ? const Color(0xFFFF6B35) // oranye jika tersedia
        : const Color(0xFFCCCCCC); // abu jika locked

    final outerBorderAlpha = isLocked ? 0.20 : 0.75;

    // Warna background card
    Color? cardBgColor;
    if (isCompleted) {
      cardBgColor = const Color(0xFFF0FFF4); // hijau muda
    } else if (isAvailable) {
      cardBgColor = Colors.white;
    } else {
      cardBgColor = const Color(0xFFF5F5F5); // abu muda
    }

    return GestureDetector(
      onTap: () => controller.onCardTap(card),
      child: Stack(
        children: [
          // ── Layer 1: border luar ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.6)
                    : _strokeDark.withValues(alpha: outerBorderAlpha),
                width: 2.5,
              ),
            ),
          ),

          // ── Layer 2: konten dalam (gap 8px dari tepi) ─────────────
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.30)
                      : _strokeDark.withValues(alpha: isLocked ? 0.15 : 0.55),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Nomor card (angka dengan stroke) ──────────────
                  Stack(
                    children: [
                      Text(
                        card.cardNumber.toString().padLeft(2, '0'),
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
                            ..color = isLocked
                                ? Colors.grey.shade400
                                : const Color(0xFF383838),
                        ),
                      ),
                      Text(
                        card.cardNumber.toString().padLeft(2, '0'),
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

                  // ── Baris bawah: level badge + status icon ─────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Badge level
                      _buildLevelBadge(card.level, isLocked),
                      // Icon status
                      _buildStatusIcon(card),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Overlay abu jika locked ────────────────────────────────
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── LEVEL BADGE ───────────────────────────────────────────────────────────
  Widget _buildLevelBadge(String level, bool isLocked) {
    final color = isLocked
        ? Colors.grey.shade400
        : level == 'Mudah'
        ? const Color(0xFF2E7D32)
        : level == 'Sedang'
        ? const Color(0xFFE65100)
        : const Color(0xFF8B3A3A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ── STATUS ICON ───────────────────────────────────────────────────────────
  Widget _buildStatusIcon(CardWithStatus card) {
    final isLocked = card.status == CardStatus.locked;
    final boxBorderColor = isLocked ? Colors.grey.shade400 : _strokeDark;

    Widget withBox(Widget child) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: boxBorderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned(right: -5, bottom: 8, child: child),
          ],
        ),
      );
    }

    switch (card.status) {
      // FIX: replay menggunakan icon centang sama seperti completed
      case CardStatus.completed:
      case CardStatus.replay:
        return withBox(
          Image.asset(
            'assets/images/icon_check.png',
            width: 42,
            height: 42,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.check_circle_rounded,
              size: 28,
              color: Color(0xFF2E7D32),
            ),
          ),
        );

      case CardStatus.available:
        return withBox(
          Image.asset(
            'assets/images/icon_question.png',
            width: 42,
            height: 42,
            errorBuilder: (_, __, ___) => const Text(
              '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFFCC3333),
              ),
            ),
          ),
        );

      case CardStatus.locked:
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn),
          child: Image.asset(
            'assets/images/icon_lock.png',
            width: 26,
            height: 26,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.lock_rounded, size: 22, color: Colors.grey[400]),
          ),
        );
    }
  }
}