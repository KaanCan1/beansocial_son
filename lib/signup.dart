import 'dart:convert';

import 'package:beansocial/footerr.dart';
import 'package:beansocial/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Otomatik giriş yap
        final loginResponse = await http.post(
          Uri.parse('http://localhost:3000/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        if (loginResponse.statusCode == 200) {
          final loginData = jsonDecode(loginResponse.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('user_id', loginData['user']['id']);
          await prefs.setString('email', loginData['user']['email']);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        } else {
          if (mounted) {
            _showMessage(
                "Kayıt başarılı fakat otomatik giriş yapılamadı. Lütfen giriş yapın.");
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        final decoded = jsonDecode(response.body);
        final message = decoded['message'] ?? 'Kayıt başarısız';
        final error = decoded['error'] ?? '';
        _showMessage("Kayıt başarısız: $message $error");
      }
    } catch (e) {
      _showMessage("Kayıt başarısız: ${e.toString()}");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildInput(String label,
      {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.brown),
        filled: true,
        fillColor: const Color(0xFFFAF5F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Header(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 400),
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/animasyon.json',
                    height: 200,
                    repeat: true,
                  ),
                  const SizedBox(height: 20),
                  _buildInput('Ad Soyad', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildInput('Email', controller: _emailController),
                  const SizedBox(height: 16),
                  _buildInput('Şifre',
                      isPassword: true, controller: _passwordController),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Zaten hesabınız var mı? Giriş yapın'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Footerr(children: []),
          ],
        ),
      ),
    );
  }
}
