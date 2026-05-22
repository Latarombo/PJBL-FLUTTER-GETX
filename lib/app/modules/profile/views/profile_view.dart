import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f4e4),
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background Image Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_profilePage.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),

            // White Card Section with Avatar Overlap
            Transform.translate(
              offset: const Offset(0, -60),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Card Background
                  Container(
                    padding: const EdgeInsets.only(
                      top: 80,
                      bottom: 0,
                      left: 24,
                      right: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xfff9f4e4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        // Username
                        const Text(
                          'Jhon Doe',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(
                                0xfff8843f,
                              ).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                icon: Icons.star,
                                label: 'POIN',
                                value: '6370',
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                icon: Icons.public,
                                label: 'PERINGKAT',
                                value: '3',
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                icon: Icons.trending_up,
                                label: 'PRESENTASE',
                                value: '87%',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pengaturan akun',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildMenuButton(
                          title: 'Ganti Nama',
                          onTap: () =>
                              controller.showFeatureSnackbar('Ganti Nama'),
                        ),
                        const SizedBox(height: 12),

                        _buildMenuButton(
                          title: 'Ganti Sandi',
                          onTap: () =>
                              controller.showFeatureSnackbar('Ganti Sandi'),
                        ),
                        const SizedBox(height: 12),

                        _buildMenuButton(
                          title: 'Ganti Email',
                          onTap: () =>
                              controller.showFeatureSnackbar('Ganti Email'),
                        ),
                        const SizedBox(height: 12),

                        _buildMenuButton(
                          title: 'Ajak teman',
                          onTap: () =>
                              controller.showFeatureSnackbar('Ajak Teman'),
                        ),
                        const SizedBox(height: 12),

                        // Log Out - panggil controller.logout()
                        _buildMenuButton(
                          title: 'Log out',
                          onTap: controller.logout,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),

                  // Avatar positioned to overlap at the top
                  Positioned(
                    top: -60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: AssetImage('assets/images/user.png'),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.white, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xfff8843f).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A574).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.play_arrow, color: Colors.black87, size: 28),
          ],
        ),
      ),
    );
  }
}
