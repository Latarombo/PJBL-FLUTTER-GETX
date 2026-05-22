import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB85C52), Color(0xFFD4896B), Color(0xFFE4A67C)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: controller.fadeAnimation,
                child: SlideTransition(
                  // Ganti Tween<Offset> ke animasi berbasis scale/translate
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0, -0.30),
                  ).animate(controller.slideAnimation),
                  child: Image.asset(
                    'assets/images/logo_mascot.png',
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              FadeTransition(
                opacity: controller.textFadeAnimation,
                child: Transform.translate(
                  offset: const Offset(0, -50),
                  child: Image.asset(
                    'assets/images/logo_name.png',
                    width: 280,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
