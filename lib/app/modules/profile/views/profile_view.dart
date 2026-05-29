import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/modules/profile/controllers/profile_controller.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/widgets/user_avatar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Dummy: 0 dari 20 unlocked
    final List<bool> medalStatus = List.generate(20, (_) => false);
    final int collected = medalStatus.where((e) => e).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F4E4),
      extendBody: true,
      body: Column(
        children: [
          _buildFixedTop(authController),
          Expanded(
            child: _buildScrollableMedals(
              medalStatus: medalStatus,
              collected: collected,
            ),
          ),
        ],
      ),
    );
  }

  // ── FIXED TOP SECTION ─────────────────────────────────────────────────────
  Widget _buildFixedTop(AuthController authController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header background + avatar ─────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/bg_profilePage.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B3A3A), Color(0xFFB85C52)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit Akun button
            Positioned(
              top: MediaQuery.of(Get.context!).padding.top + 10,
              right: 16,
              child: GestureDetector(
                onTap: controller.goToEditAccount,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Edit Akun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar
            Positioned(
              bottom: -50,
              child: UserAvatar(
                size: 100,
                borderWidth: 4,
                borderColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 60),

        // ── Username (real-time via Obx) ───────────────────────────────────
        Obx(() {
          final name = authController.username.isNotEmpty
              ? authController.username
              : 'User';
          return Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF270F0F),
            ),
          );
        }),

        const SizedBox(height: 20),

        // ── Stats Card (semua real-time via Obx) ───────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF8843F).withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── POIN ──────────────────────────────────────────────────
                Obx(
                  () => _buildStatItem(
                    icon: Icons.star,
                    label: 'POIN',
                    value: '${authController.totalPoints}',
                  ),
                ),
                _buildVerticalDivider(),

                // ── RANKING — dengan loading indicator ───────────────────
                Obx(() {
                  if (controller.isLoadingRank.value) {
                    return Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.public,
                            size: 24,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'RANGKING',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFB85C52),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final rankVal = authController.rank > 0
                      ? '#${authController.rank}'
                      : '-';
                  return _buildStatItem(
                    icon: Icons.public,
                    label: 'RANGKING',
                    value: rankVal,
                  );
                }),
                _buildVerticalDivider(),

                // ── PERSENTASE ────────────────────────────────────────────
                Obx(() {
                  final rate = authController.correctRate;
                  final display = rate > 0
                      ? '${rate.toStringAsFixed(0)}%'
                      : '0%';
                  return _buildStatItem(
                    icon: Icons.trending_up,
                    label: 'PRESENTASE',
                    value: display,
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── SCROLLABLE MEDALS ─────────────────────────────────────────────────────
  Widget _buildScrollableMedals({
    required List<bool> medalStatus,
    required int collected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medali Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF270F0F),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 3),
                height: 3,
                width: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFB85C52),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Selesaikan berbagai quiz seru untuk mengumpulkan\nfragmen dan membuka medali spesial!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF270F0F),
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'Dikumpulkan: '),
                TextSpan(
                  text: '$collected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB85C52),
                    fontSize: 17,
                  ),
                ),
                TextSpan(
                  text: '/${medalStatus.length} medali',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: medalStatus.length,
              itemBuilder: (context, index) =>
                  _buildMedalItem(index: index, isUnlocked: medalStatus[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ── SINGLE MEDAL ITEM ──────────────────────────────────────────────────────
  Widget _buildMedalItem({required int index, required bool isUnlocked}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isUnlocked ? const Color(0xFFFFF3E0) : const Color(0xFFF0EBE0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: ColorFiltered(
              colorFilter: isUnlocked
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.saturation,
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
                'assets/images/badge_master.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _buildFallbackBadge(isUnlocked: isUnlocked),
              ),
            ),
          ),
          if (!isUnlocked)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackBadge({required bool isUnlocked}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUnlocked
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isUnlocked ? const Color(0xFFB8860B) : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          isUnlocked ? Icons.military_tech : Icons.lock_rounded,
          color: isUnlocked ? Colors.white : Colors.grey[500],
          size: 26,
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Widget _buildVerticalDivider() =>
      Container(width: 1, height: 48, color: Colors.grey[300]);

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF270F0F),
            ),
          ),
        ],
      ),
    );
  }
}
