import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/password_recovery_success/controllers/password_recovery_success_controller.dart';
import 'package:santarana/shared/widgets/app_buttons.dart';

class PasswordRecoverySuccessView
    extends GetView<PasswordRecoverySuccessController> {
  const PasswordRecoverySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon_succes.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 48),

                // Title
                const Text(
                  'Password berhasil\ndipulihkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Selamat datang! Anda berhasil Login. Siap uji pengetahuanmu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Countdown - Obx untuk reaktif
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFB8886F).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: Color(0xFFB8886F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mengarahkan dalam ${controller.countdown.value} detik',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Manual navigation button
                PrimaryButton(
                  text: 'Ke Halaman Utama',
                  onPressed: controller.navigateToHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
