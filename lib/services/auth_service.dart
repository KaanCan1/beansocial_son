import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class AuthService {
  static bool _isLoggedIn = false;

  static void setLoggedIn(bool value) {
    _isLoggedIn = value;
  }

  static bool isLoggedInSync() {
    return _isLoggedIn;
  }

  static Future<bool> login(String email, String password) async {
    if (!kIsWeb) {
      Get.snackbar(
        'Hata',
        'Bu uygulama sadece web tarayıcısında çalışmaktadır.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    try {
      final response = await http
          .post(
        Uri.parse('${Config.baseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        Config.timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Bağlantı zaman aşımına uğradı');
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('user_id', responseData['user']['id']);
        await prefs.setString('email', responseData['user']['email']);
        await prefs.setString('userName', responseData['user']['name'] ?? '');
        await prefs.setString(
            'username', responseData['user']['username'] ?? '');
        await prefs.setString(
            'userImage', responseData['user']['profileImage'] ?? '');
        setLoggedIn(true);
        return true;
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Giriş başarısız';
        } catch (e) {
          errorMessage = 'Giriş başarısız: ${response.statusCode}';
        }

        Get.snackbar(
          'Hata',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'Bağlantı hatası: ${e.toString()}';
      Get.snackbar(
        'Bağlantı Hatası',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setLoggedIn(false);
    Get.offAllNamed('/login');
  }

  static Future<bool> isLoggedIn() async {
    if (!kIsWeb) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (!isLoggedIn) {
        await logout();
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    if (!kIsWeb) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        await logout();
        return null;
      }
      // API'den user info çekmek istersen burada token olmadan çekebilirsin
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkAuthAndRedirect(context) async {
    if (!kIsWeb) {
      Get.offAllNamed('/login');
      return false;
    }
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      Get.offAllNamed('/login');
      return false;
    }
    return true;
  }
}
