import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/services/auth_service.dart';

class SplashController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController fadeController;
  late AnimationController slideController;

  late Animation<double> fadeAnimation;
  late Animation<double> slideAnimation;
  late Animation<double> textFadeAnimation;

  @override
  void onInit() {
    super.onInit();
    _initAnimations();
    _startFlow();
  }

  void _initAnimations() {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeIn,
    );

    slideAnimation = CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOut,
    );

    textFadeAnimation = CurvedAnimation(
      parent: slideController,
      curve: Curves.easeIn,
    );
  }

  Future<void> _startFlow() async {
    await fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    await slideController.forward();
    await Future.delayed(const Duration(milliseconds: 2800));

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final authController = Get.find<AuthController>();
      final userData = await AuthService().getUserData(firebaseUser.uid);
      if (userData != null) {
        authController.setUser(userData);
      }
      Get.offAllNamed(Routes.APP);
    } else {
      Get.offAllNamed(Routes.SIGN_IN);
    }
  }

  @override
  void onClose() {
    fadeController.dispose();
    slideController.dispose();
    super.onClose();
  }
}
