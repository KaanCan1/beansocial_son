import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService extends GetxService {
  final String baseUrl = Config.baseUrl;

  static ApiService get to => Get.find();

  Future<ApiService> init() async {
    return this;
  }

  // Kullanıcı bilgilerini getir
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Kullanıcı bilgileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kullanıcı bilgileri alınırken hata oluştu: $e');
    }
  }

  // Kullanıcının tariflerini getir
  Future<List<Map<String, dynamic>>> getUserRecipes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recipes/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        return recipes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Tarifler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Tarifler alınırken hata oluştu: $e');
    }
  }

  // Kullanıcı profilini güncelle
  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Kullanıcı güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kullanıcı güncellenirken hata oluştu: $e');
    }
  }

  // Profil resmi yükle
  Future<Map<String, dynamic>> uploadProfileImage(
      String userId, String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/upload-profile-image'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['userId'] = userId;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Profil resmi yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Profil resmi yüklenirken hata oluştu: $e');
    }
  }
}
