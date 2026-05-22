import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/settings/controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25,
                constraints: const BoxConstraints(
                  minHeight: 150,
                  maxHeight: 220,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_profilePage.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pengaturan',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Settings Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Volume Suara Toggle - Obx untuk reaktif
                    Obx(
                      () => _buildToggleCard(
                        icon: Icons.volume_up,
                        title: 'Volume suara',
                        value: controller.volumeSuara.value,
                        onChanged: controller.toggleVolumeSuara,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dering Ponsel Toggle
                    Obx(
                      () => _buildToggleCard(
                        icon: Icons.phone_android,
                        title: 'Dering ponsel',
                        value: controller.deringPonsel.value,
                        onChanged: controller.toggleDeringPonsel,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notifikasi Toggle
                    Obx(
                      () => _buildToggleCard(
                        icon: Icons.notifications,
                        title: 'Notifikasi',
                        value: controller.notifikasi.value,
                        onChanged: controller.toggleNotifikasi,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Buku Panduan
                    _buildNavigationCard(
                      icon: Icons.menu_book,
                      title: 'Buku panduan',
                      onTap: () => controller.showComingSoon('Buku panduan'),
                    ),
                    const SizedBox(height: 24),

                    // Lainnya Section Header
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Lainnya',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    _buildNavigationCard(
                      title: 'Tentang Kami',
                      onTap: () => controller.showComingSoon('Tentang Kami'),
                    ),
                    const SizedBox(height: 12),

                    _buildNavigationCard(
                      title: 'Kontak Kami',
                      onTap: () => controller.showComingSoon('Kontak Kami'),
                    ),
                    const SizedBox(height: 12),

                    _buildNavigationCard(
                      title: 'Email Kami',
                      onTap: () => controller.showComingSoon('Email Kami'),
                    ),
                    const SizedBox(height: 12),

                    _buildNavigationCard(
                      title: 'Bantuan & Dukungan',
                      onTap: () =>
                          controller.showComingSoon('Bantuan & Dukungan'),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 80,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xfff8843f).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A574).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF8B5A3C),
            activeTrackColor: const Color(0xFFE8B88A),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    IconData? icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xfff8843f).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A574).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black87, size: 24),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black87,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
