import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/app_shell.dart';
import 'package:santarana/app/modules/weekly_mission/controller/weekly_mission_controller.dart';
import 'package:santarana/app/modules/home/controllers/home_controller.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/category_model.dart';
import 'package:santarana/shared/models/weekly_mission_model.dart';
import 'package:santarana/shared/widgets/user_avatar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. HEADER ──────────────────────────────────────
                  _buildHeader(authController),

                  // Space untuk card Aktivitas Terakhir yang overlap
                  const SizedBox(height: 80),

                  // ── 2. KATEGORI GAME ───────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Kategori Game',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGameCategories(),

                  const SizedBox(height: 20),

                  // ── 3. TEKS PROMO ──────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Ayo! Selesaikan kuis terbaru kami dapatkan point tambahan dari tantangan harian',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff714f4c),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 4. FEATURED GAME CARD ──────────────────────────
                  _buildFeaturedGameCard(),

                  const SizedBox(height: 28),

                  // ── 5. MISI EKSPLOR HARIAN ─────────────────────────
                  _buildMisiEksplorHarian(),

                  const SizedBox(height: 100),
                ],
              ),

              // ── Karakter maskot (overlap di header) ───────────────
              Positioned(
                top: 100,
                right: 40,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/character_game.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ── Aktivitas Terakhir Card (overlap ke bawah header) ─
              Positioned(
                top: 220,
                left: 0,
                right: 0,
                child: _buildAktivitasTerakhirCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(AuthController authController) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/bg_home_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(
                          'Halo,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = const Color(0xFFC4986A),
                          ),
                        ),
                        const Text(
                          'Halo,',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final name = authController.username;
                      return Stack(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = const Color(0xFFC4986A),
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                        size: 32,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            Get.find<AppShellController>().changePage(2),
                        child: UserAvatar(
                          size: 32,
                          borderWidth: 2,
                          borderColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Text(
                      'Total Poin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = const Color(0xFFC4986A),
                      ),
                    ),
                    const Text(
                      'Total Poin',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFC4986A).withValues(alpha: 0.73),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      '${authController.totalPoints}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── AKTIVITAS TERAKHIR ────────────────────────────────────────────────────
  Widget _buildAktivitasTerakhirCard() {
    return Obx(() {
      final last = controller.lastActivity.value;

      if (last == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5ECD7),
                  ),
                  child: const Icon(
                    Icons.sports_esports_rounded,
                    color: Color(0xFFB8860B),
                    size: 38,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aktivitas Terakhir',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Anda belum mempunyai aktivitas,\nAyo mulai bermain!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.categories.isNotEmpty) {
                                controller.goToKategori(
                                  controller.categories.first.name,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B3A3A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Mulai Main',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

      return GestureDetector(
        onTap: () => controller.goToKategori(last.categoryName),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF5A8B7E),
                    image: last.imagePath.isNotEmpty
                        ? DecorationImage(
                            image: AssetImage(last.imagePath),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Aktivitas Terakhir',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        last.categoryName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Skor terakhir: ${last.lastScore}%  •  ${last.attempts}x main',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: last.lastScore / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFB347),
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${last.lastScore}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── FEATURED GAME CARD ────────────────────────────────────────────────────
  Widget _buildFeaturedGameCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/promo_game.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_mascot2.png',
                          width: 35,
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cobalah game terbaru kami!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '21/01/2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── KATEGORI GAME ─────────────────────────────────────────────────────────
  Widget _buildGameCategories() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFB347)),
          );
        }
        if (controller.categories.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada kategori',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final cat = controller.categories[i];
            return _buildCategoryCard(cat);
          },
        );
      }),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return GestureDetector(
      onTap: () => controller.goToKategori(category.name),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(category.imagePath),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
          color: const Color(0xFF5A8B7E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── MISI EKSPLOR HARIAN ───────────────────────────────────────────────────
  Widget _buildMisiEksplorHarian() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/calender.png', width: 40, height: 40),
              const SizedBox(width: 10),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -2,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB85C52).withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Text(
                    'Misi Eksplor Harian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3D1C10),
                      letterSpacing: 0.2,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selesaikan misi dan dapatkan medali:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF714F4C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                'assets/images/badge_master.png',
                width: 28,
                height: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Grid misi dari DailyMissionController ─────────────────
          _buildMissionGrid(),
        ],
      ),
    );
  }

  // ── MISSION GRID — membaca dari DailyMissionController ───────────────────
  Widget _buildMissionGrid() {
    final missionCtrl = Get.find<WeeklyMissionController>();

    return Obx(() {
      if (missionCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB347)),
        );
      }

      final items = missionCtrl.missionsWithStatus;

      if (items.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Misi minggu ini belum tersedia.\nCoba lagi nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF714F4C)),
            ),
          ),
        );
      }

      final regular = items.where((m) => !m.slot.isSpecial).toList();
      final special = items.cast<WeeklyMissionSlotWithStatus?>().firstWhere(
        (m) => m?.slot.isSpecial == true,
        orElse: () => null,
      );

      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: regular.length,
            itemBuilder: (_, i) => _buildMissionCard(
              regular[i],
              onTap: () => missionCtrl.onMissionTap(regular[i]),
            ),
          ),
          if (special != null) ...[
            const SizedBox(height: 14),
            _buildSpecialMissionCard(
              special,
              onTap: () => missionCtrl.onMissionTap(special),
            ),
          ],
        ],
      );
    });
  }

  // ── MISSION CARD ──────────────────────────────────────────────────────────
  Widget _buildMissionCard(
    WeeklyMissionSlotWithStatus item, {
    required VoidCallback onTap,
  }) {
    final isCompleted = item.status == WeeklyMissionStatus.completed;
    final isInProgress = item.status == WeeklyMissionStatus.inProgress;
    final isLocked = item.status == WeeklyMissionStatus.locked;
    final isExpired = item.status == WeeklyMissionStatus.expired;
    final hasImage = item.slot.imagePath != null;

    const strokeColor = Color(0xFF3D1C10);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: strokeColor, width: 2.5),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    ColorFiltered(
                      colorFilter: (isLocked || isExpired)
                          ? const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.color,
                            ),
                      child: Image.asset(
                        item.slot.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.white),
                      ),
                    )
                  else
                    Container(color: Colors.white),

                  if (hasImage)
                    Container(
                      color: Colors.black.withValues(
                        alpha: (isLocked || isExpired) ? 0.25 : 0.30,
                      ),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF3D1C10).withValues(alpha: 0.60),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Nomor misi
                        Stack(
                          children: [
                            Text(
                              item.slot.day.toString().padLeft(2, '0'),
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
                            Text(
                              item.slot.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 36 * 0.08,
                                color: (isCompleted || isInProgress)
                                    ? const Color(0xFFFFD700)
                                    : hasImage
                                    ? Colors.white
                                    : const Color(0xFFCCCCCC),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.slot.difficulty,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: hasImage
                                    ? Colors.white
                                    : (isLocked || isExpired)
                                    ? Colors.grey[600]
                                    : const Color(0xFF714F4C),
                              ),
                            ),
                            _buildStatusIcon(item, hasImage: hasImage),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STATUS ICON ───────────────────────────────────────────────────────────
  Widget _buildStatusIcon(
    WeeklyMissionSlotWithStatus item, { // ← ganti
    bool hasImage = false,
  }) {
    final boxBorderColor =
        (item.status == WeeklyMissionStatus.locked ||
            item.status == WeeklyMissionStatus.expired)
        ? (hasImage ? Colors.white : Colors.grey.shade500)
        : const Color(0xFF3D1C10);

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

    switch (item.status) {
      case WeeklyMissionStatus.completed:
        return withBox(
          Image.asset(
            'assets/images/icon_check.png',
            width: 42,
            height: 42,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.check, size: 20, color: Color(0xFF2E7D32)),
          ),
        );

      case WeeklyMissionStatus.inProgress:
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

      case WeeklyMissionStatus.expired:
      case WeeklyMissionStatus.locked:
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            hasImage ? Colors.white : Colors.grey.shade500,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'assets/images/icon_lock.png',
            width: 26,
            height: 26,
            errorBuilder: (_, __, ___) => Icon(
              Icons.lock_rounded,
              size: 22,
              color: hasImage ? Colors.white : Colors.grey[500],
            ),
          ),
        );
    }
  }

  // ── SPECIAL MISSION CARD ──────────────────────────────────────────────────
  Widget _buildSpecialMissionCard(
    WeeklyMissionSlotWithStatus item, {
    required VoidCallback onTap,
  }) {
    final isCompleted = item.status == WeeklyMissionStatus.completed;
    final isInProgress = item.status == WeeklyMissionStatus.inProgress;
    final hasImage = item.slot.imagePath != null;
    const strokeColor = Color(0xFF3D1C10);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: strokeColor, width: 2.5),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  if (hasImage)
                    ColorFiltered(
                      colorFilter: (isCompleted || isInProgress)
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.color,
                            )
                          : const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                      child: Image.asset(
                        item.slot.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.white),
                      ),
                    )
                  else
                    Container(color: Colors.white),

                  Container(color: Colors.black.withValues(alpha: 0.25)),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF3D1C10).withValues(alpha: 0.20),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Text(
                              item.slot.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 42,
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
                            Text(
                              item.slot.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 36 * 0.08,
                                color: (isCompleted || isInProgress)
                                    ? const Color(0xFFFFD700)
                                    : Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.slot.difficulty,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            _buildStatusIcon(item, hasImage: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
