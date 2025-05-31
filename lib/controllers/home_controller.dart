import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class HomeController extends GetxController {
  final recipes = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final error = RxnString();

  Future<void> loadRecipes() async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/recipes'),
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
}
