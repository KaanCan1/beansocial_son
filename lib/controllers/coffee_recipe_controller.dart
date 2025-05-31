import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class CoffeeRecipeController extends GetxController {
  final _baseUrl = Config.baseUrl;
  final isLoading = false.obs;
  final error = ''.obs;
  final recipes = <Map<String, dynamic>>[].obs;
  final selectedImagePath = Rxn<String>();
  final _picker = ImagePicker();
  String? currentUserId;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => _loadCurrentUser());
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('user_id');
  }

  Future<void> loadRecipes() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recipes'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        recipes.value = List<Map<String, dynamic>>.from(data);
      } else {
        error.value = 'Tarifler alınamadı: ${response.statusCode}';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createRecipe(
      Map<String, dynamic> recipeData, File? imageFile) async {
    try {
      isLoading.value = true;

      // Kullanıcı ID'sini al
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // authorId'yi ekle
      recipeData['authorId'] = userId;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/recipes'),
      );

      // Form verilerini ekle
      recipeData.forEach((key, value) {
        if (key == 'parameters') {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Resim dosyasını ekle
      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        await loadRecipes();
        selectedImagePath.value = null;
        return true;
      } else {
        final errorMessage = _parseErrorMessage(response);
        throw Exception('Tarif eklenirken bir hata oluştu: $errorMessage');
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Bilinmeyen hata';
    } catch (_) {
      return 'HTTP ${response.statusCode}';
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      isLoading.value = true;
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/recipes/$recipeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        recipes.removeWhere((recipe) => recipe['id'] == recipeId);
        Get.snackbar(
          '✅ Başarılı',
          'Tarif başarıyla silindi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      } else {
        throw Exception('Tarif silinirken bir hata oluştu');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Hata',
        'Tarif silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserRecipes(String userId) async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recipes/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['recipes'] != null) {
          recipes.value = List<Map<String, dynamic>>.from(body['recipes']);
        } else {
          recipes.value = [];
        }
      } else {
        error.value = 'Tarifler alınamadı: ${response.statusCode}';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
