import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/sign_in/controllers/sign_in_controller.dart';
import 'package:santarana/shared/widgets/app_buttons.dart';
import 'package:santarana/shared/widgets/app_input_field.dart';
import 'package:santarana/shared/widgets/social_login_button.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background Image (atas) ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.30,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_login.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),

          // ── Tombol Register (pojok kanan atas) ───────────────────
          Positioned(
            top: topPadding,
            right: 8,
            child: TextButton(
              onPressed: controller.goToRegister,
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Form Card (putih, mengisi sisa layar) ────────────────
          Positioned(
            top: screenHeight * 0.22,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Judul ──────────────────────────────────────
                    const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silahkan masuk ke akunmu untuk melanjutkan petualangan di SantaraNa!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Email ──────────────────────────────────────
                    InputField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'Email',
                    ),
                    const SizedBox(height: 16),

                    // ── Password ───────────────────────────────────
                    Obx(
                      () => InputField(
                        controller: controller.passwordController,
                        hint: 'Password',
                        obscureText: controller.obscurePassword.value,
                        toggleObscure: controller.toggleObscurePassword,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Lupa Password ──────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.goToForgotPassword,
                        child: Text(
                          'lupa password?*',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Masuk ───────────────────────────────
                    Obx(
                      () => PrimaryButton(
                        text: controller.isLoading.value
                            ? 'Memproses...'
                            : 'Masuk',
                        onPressed: controller.isLoading.value
                            ? () {}
                            : controller.handleSignIn,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Google ─────────────────────────────────────
                    SocialLoginButton(
                      text: 'Lanjut dengan Google',
                      iconPath: 'assets/images/icon_google.png',
                      onPressed: controller.handleGoogleSignIn,
                    ),
                    const SizedBox(height: 16),

                    // ── Facebook ───────────────────────────────────
                    SocialLoginButton(
                      text: 'Lanjut dengan Facebook',
                      iconPath: 'assets/images/icon_facebook.png',
                      onPressed: controller.handleFacebookSignIn,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
