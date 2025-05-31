import 'package:beansocial/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final error = RxnString();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      error.value = 'Lütfen email ve şifre alanlarını doldurun.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (result) {
        Get.offAllNamed('/profile');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
