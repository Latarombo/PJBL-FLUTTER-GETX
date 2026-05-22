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
    return Scaffold(
      body: Stack(
        children: [
          // Background Image - Only at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_login.png'),
                  fit: BoxFit.cover,
                ),
              ),
              // Dark overlay
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Header with Login button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flexible space
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                    // Register Form - This will overlap the background
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),

                            // Subtitle
                            Text(
                              'Silahkan isi data diri anda untuk bergabung dengan SantaraNa dan mulai pertualanganmu!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 32),

                            // Email Field
                            InputField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              hint: 'Email',
                              onSubmitted: (_) => controller.handleRegister(),
                            ),
                            SizedBox(height: 16),

                            // Username Field
                            InputField(
                              controller: controller.usernameController,
                              hint: 'Username',
                              onSubmitted: (_) => controller.handleRegister(),
                            ),
                            SizedBox(height: 16),

                            // Password Field
                            Obx(
                              () => InputField(
                                controller: controller.passwordController,
                                hint: 'Password',
                                obscureText: controller.obscurePassword.value,
                                toggleObscure: controller.toggleObscurePassword,
                              ),
                            ),

                            SizedBox(height: 8),

                            // Confirm Password Field
                            Obx(
                              () => InputField(
                                controller:
                                    controller.confirmPasswordController,
                                hint: 'Confirm password',
                                obscureText:
                                    controller.obscureConfirmPassword.value,
                                toggleObscure:
                                    controller.toggleObscureConfirmPassword,
                              ),
                            ),
                            SizedBox(height: 24),

                            // Register Button
                            PrimaryButton(
                              text: 'Daftar',
                              onPressed: controller.handleRegister,
                            ),
                            SizedBox(height: 24),

                            // Google Sign In Button
                            SocialLoginButton(
                              text: 'Lanjut dengan Google',
                              iconPath: 'assets/images/icon_google.png',
                              onPressed: controller.handleGoogleSignIn,
                            ),

                            SizedBox(height: 16),
                            // Facebok Sign In button
                            SocialLoginButton(
                              text: 'Lanjut dengan Facebook',
                              iconPath: 'assets/images/icon_facebook.png',
                              onPressed: controller.handleFacebookSignIn,
                            ),
                            SizedBox(height: 32),
                          ],
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
    );
  }
}
