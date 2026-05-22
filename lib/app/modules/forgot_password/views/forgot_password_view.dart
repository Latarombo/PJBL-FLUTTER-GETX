import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/forgot_password/controllers/forgot_password_controller.dart';
import 'package:santarana/shared/widgets/app_buttons.dart';
import 'package:santarana/shared/widgets/app_input_field.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.30,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_login.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                    color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),

            // Header
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: controller.goBack,
                    ),
                    const Expanded(
                      child: Text(
                        'Lupa Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Draggable Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.75,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(context).viewInsets.bottom,
                    ),
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 12, bottom: 20),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/ilustration_forgotPass.png',
                              width: 220,
                              height: 220,
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Lupa password?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff270f0f),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Silakan tulis email Anda untuk menerima kode konfirmasi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email Input
                            InputField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              hint: 'Email',
                              onSubmitted: (_) =>
                                  controller.validEmailSubmit(),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            PrimaryButton(
                              text: 'Konfirmasi Email',
                              onPressed: controller.validEmailSubmit,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
