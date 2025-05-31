import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  final RxList recipes = [].obs;
  final RxString selectedProfileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile('');
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        user.value = userData;
        name.value = userData['name'] ?? '';
        email.value = userData['email'] ?? '';
        username.value = userData['username'] ?? '';
        profileImageUrl.value = userData['profileImage'] ?? '';
        await loadUserRecipes(userId);
      } else {
        throw Exception('Profil bilgileri alınamadı');
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserRecipes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/api/users/$userId/recipes'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipesData = json.decode(response.body);
        recipes.value = recipesData;
      } else {
        throw Exception('Tarifler alınamadı');
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await http.put(
        Uri.parse('${_apiService.baseUrl}/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        user.value = updatedData;
        name.value = updatedData['name'] ?? '';
        email.value = updatedData['email'] ?? '';
        username.value = updatedData['username'] ?? '';
        Get.snackbar(
          'Başarılı',
          'Profil bilgileri güncellendi',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Profil güncellenemedi');
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfilePicture(String userId, String imagePath) async {
    try {
      isLoading.value = true;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/api/users/$userId/profile-image'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        imagePath,
      ));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        profileImageUrl.value = responseData['profileImage'] ?? '';
        user.value['profileImage'] = profileImageUrl.value;
        Get.snackbar(
          'Başarılı',
          'Profil resmi güncellendi',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Profil resmi yüklenemedi');
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.');
      }
      final response = await http.delete(
        Uri.parse('${_apiService.baseUrl}/api/recipes/$recipeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        recipes.removeWhere((recipe) => recipe['id'] == recipeId);
        Get.snackbar(
          'Başarılı',
          'Tarif silindi',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Tarif silinemedi');
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
