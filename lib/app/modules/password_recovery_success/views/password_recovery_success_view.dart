import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/password_recovery_success_controller.dart';

class PasswordRecoverySuccessView
    extends GetView<PasswordRecoverySuccessController> {
  const PasswordRecoverySuccessView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PasswordRecoverySuccessView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PasswordRecoverySuccessView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
