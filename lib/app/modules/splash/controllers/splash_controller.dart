import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:santarana/app/routes/app_pages.dart';

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

    // GetX navigation - tidak butuh context!
    Get.offAllNamed(Routes.SIGN_IN);
  }

  @override
  void onClose() {
    fadeController.dispose();
    slideController.dispose();
    super.onClose();
  }
}
