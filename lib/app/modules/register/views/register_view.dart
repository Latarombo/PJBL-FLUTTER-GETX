import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:santarana/app/modules/register/controllers/register_controller.dart';
import 'package:santarana/shared/widgets/app_buttons.dart';
import 'package:santarana/shared/widgets/app_input_field.dart';
import 'package:santarana/shared/widgets/social_login_button.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background Image (atas) — FIXED, tidak ikut scroll ──────
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

          // ── Tombol Login (pojok kanan atas) ──────────────────────────
          Positioned(
            top: topPadding,
            right: 8,
            child: TextButton(
              onPressed: controller.goBack,
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Form Card (putih, mengisi sisa layar) ────────────────────
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
                    // ── Judul ──────────────────────────────────────────
                    const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Subtitle ───────────────────────────────────────
                    Text(
                      'Silahkan isi data diri anda untuk bergabung dengan SantaraNa dan mulai petualanganmu!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Email ──────────────────────────────────────────
                    InputField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'Email',
                      onSubmitted: (_) => controller.handleRegister(),
                    ),
                    const SizedBox(height: 16),

                    // ── Username ───────────────────────────────────────
                    InputField(
                      controller: controller.usernameController,
                      hint: 'Username',
                      onSubmitted: (_) => controller.handleRegister(),
                    ),
                    const SizedBox(height: 16),

                    // ── Password ───────────────────────────────────────
                    Obx(
                      () => InputField(
                        controller: controller.passwordController,
                        hint: 'Password',
                        obscureText: controller.obscurePassword.value,
                        toggleObscure: controller.toggleObscurePassword,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Confirm Password ───────────────────────────────
                    Obx(
                      () => InputField(
                        controller: controller.confirmPasswordController,
                        hint: 'Confirm password',
                        obscureText: controller.obscureConfirmPassword.value,
                        toggleObscure: controller.toggleObscureConfirmPassword,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Daftar ──────────────────────────────────
                    Obx(
                      () => PrimaryButton(
                        text: controller.isLoading.value
                            ? 'Memproses...'
                            : 'Daftar',
                        onPressed: controller.isLoading.value
                            ? () {}
                            : controller.handleRegister,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Google ─────────────────────────────────────────
                    SocialLoginButton(
                      text: 'Lanjut dengan Google',
                      iconPath: 'assets/images/icon_google.png',
                      onPressed: controller.handleGoogleSignIn,
                    ),
                    const SizedBox(height: 16),

                    // ── Facebook ───────────────────────────────────────
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
