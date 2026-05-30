import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:santarana/shared/models/leaderboard_model.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4E4),
      body: Stack(
        children: [
          // ── Background image (menggantikan CustomPaint painter) ──────
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_leaderboard.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                // Fallback ke gradient lama jika aset belum ada
                return CustomPaint(painter: LeaderboardBackgroundPainter());
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildPodium(),
                        const SizedBox(height: 30),
                        _buildLeaderboardList(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: _buildCurrentUserCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3A3A), Color(0xFFB85C52)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            'PERINGKAT GLOBAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return SizedBox(
      height: 340,
      child: Obx(() {
        final top = controller.top3;

        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFB347)),
          );
        }

        if (top.length < 3) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.leaderboard,
                  size: 48,
                  color: Color(0xFFFFB347),
                ),
                const SizedBox(height: 12),
                Text(
                  top.isEmpty
                      ? 'Belum ada data leaderboard'
                      : 'Butuh minimal 3 pemain\nuntuk menampilkan podium',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF270F0F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saat ini: ${top.length} pemain',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 210,
                width: double.infinity,
                child: Image.asset('assets/images/cloud.png', fit: BoxFit.fill),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 40,
              child: _buildPodiumItem(
                rank: 2,
                username: top[1].username,
                score: top[1].totalPoints,
                avatarAsset: 'assets/images/avatar4.png',
                wingsAsset: 'assets/images/rank_2.png',
                podiumColor: const Color(0xFFC0C0C0),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: _buildPodiumItem(
                rank: 1,
                username: top[0].username,
                score: top[0].totalPoints,
                avatarAsset: 'assets/images/avatar3.png',
                wingsAsset: 'assets/images/rank_1.png',
                podiumColor: const Color(0xFFFFD700),
                isFirst: true,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 40,
              child: _buildPodiumItem(
                rank: 3,
                username: top[2].username,
                score: top[2].totalPoints,
                avatarAsset: 'assets/images/user.png',
                wingsAsset: 'assets/images/rank_3.png',
                podiumColor: const Color(0xFFCD7F32),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String username,
    required int score,
    required String avatarAsset,
    required String wingsAsset,
    required Color podiumColor,
    bool isFirst = false,
  }) {
    final size = isFirst ? 89.0 : 75.0;
    final badgeSize = isFirst ? 180.0 : 120.0;

    return Column(
      children: [
        SizedBox(
          width: badgeSize,
          height: badgeSize + 20,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: (badgeSize - size) / 2,
                top: (badgeSize - size) / 2 - 10,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFC4D6),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatarAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: size * 0.6,
                        color: const Color(0xFF8B4789),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 20,
                child: Image.asset(
                  wingsAsset,
                  width: badgeSize,
                  height: badgeSize,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Center(
                  child: Stack(
                    children: [
                      Text(
                        score.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = rank == 1
                                ? const Color(0xFFB8860B)
                                : rank == 2
                                ? const Color(0xFF808080)
                                : const Color(0xfff7d9bc),
                          fontSize: isFirst ? 28 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        score.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: rank == 1
                              ? const Color(0xfff9eda5)
                              : rank == 2
                              ? const Color(0xffe7e7e7)
                              : const Color(0xffce8946),
                          fontSize: isFirst ? 28 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Transform.translate(
          offset: const Offset(0, -25),
          child: SizedBox(
            width: badgeSize + 10,
            child: Text(
              username,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isFirst ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF270F0F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFB347)),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: controller.leaderboardData
              .map((entry) => _buildLeaderboardCard(entry))
              .toList(),
        ),
      );
    });
  }

  Widget _buildLeaderboardCard(LeaderboardModel entry) {
    Gradient? cardGradient;
    Color? cardColor;

    if (entry.rank == 1) {
      cardGradient = const LinearGradient(
        colors: [Color(0xffffe802), Color(0xffffce00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (entry.rank == 2) {
      cardGradient = const LinearGradient(
        colors: [Color(0xffebecf0), Color(0xffbec0c2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (entry.rank == 3) {
      cardGradient = const LinearGradient(
        colors: [Color(0xffc18563), Color(0xff9c7a3c)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      cardColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: cardGradient,
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: entry.rank <= 3
              ? const Color.fromARGB(255, 200, 110, 92).withValues(alpha: 0.4)
              : const Color(0xffffd9cc),
          width: 2,
        ),
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
          SizedBox(
            width: 20,
            child: Text(
              entry.rank.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF270F0F),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFC4D6),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/user.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  size: 24,
                  color: Color(0xFF8B4789),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.username,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF270F0F),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.totalPoints.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF270F0F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard() {
    return Obx(() {
      final userEntry = controller.currentUserEntry;
      if (userEntry == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B3A3A), Color(0xFFB85C52)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(2, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  userEntry.rank.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff7d9bc),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC4D6),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/user.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 28,
                      color: Color(0xFF8B4789),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userEntry.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff7d9bc),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                userEntry.totalPoints.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xfff7d9bc),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Fallback painter — tetap dipertahankan jika aset belum ada
class LeaderboardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF9F4E4), Color(0xFFFFE8D6), Color(0xffd2947b)],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final sprinklePaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 3.0 + random.nextDouble() * 4;
      final colors = [
        Colors.white,
        const Color(0xFFFFE0E0).withValues(alpha: 0.5),
        const Color(0xFFFFFFCC).withValues(alpha: 0.5),
      ];
      sprinklePaint.color = colors[random.nextInt(colors.length)];
      _drawStar(canvas, Offset(x, y), starSize, sprinklePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? size : size / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
