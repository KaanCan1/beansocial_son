import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/coffee_recipe_controller.dart';
import 'coffee_recipe_form.dart';

class MyRecipesScreen extends StatefulWidget {
  final String? userId;
  const MyRecipesScreen({super.key, this.userId});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final CoffeeRecipeController controller = Get.find<CoffeeRecipeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        controller.loadUserRecipes(widget.userId!);
      } else {
        controller.loadRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kahve Tariflerim'),
        backgroundColor: Colors.brown[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CoffeeRecipeForm()),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hata: ${controller.error.value}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (widget.userId != null) {
                      controller.loadUserRecipes(widget.userId!);
                    } else {
                      controller.loadRecipes();
                    }
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        if (controller.recipes.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.coffee_outlined,
                    size: 64,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz kahve tarifi eklemediniz',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CoffeeRecipeForm()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Tarif Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.recipes.length,
          itemBuilder: (context, index) {
            final recipe = controller.recipes[index];
            Map<String, dynamic> parameters;
            try {
              parameters = Map<String, dynamic>.from(
                  jsonDecode(recipe['parameters'] as String));
            } catch (e) {
              parameters = {};
              print('Parameters parse error: $e');
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipe['imageUrl'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      child: Image.network(
                        recipe['imageUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                recipe['name'] ?? 'İsimsiz Tarif',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _showDeleteDialog(
                                context,
                                recipe['id'],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recipe['type'] ?? 'Belirtilmemiş',
                            style: TextStyle(
                              color: Colors.brown[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hazırlanış',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(recipe['description'] ?? 'Açıklama yok'),
                        const SizedBox(height: 16),
                        const Text(
                          'Parametreler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (parameters.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildParameterChip(
                                'Öğütme',
                                '${parameters['grindSize'] ?? 'Belirtilmemiş'}',
                              ),
                              _buildParameterChip(
                                'Su Sıcaklığı',
                                '${parameters['waterTemp'] ?? 'Belirtilmemiş'}°C',
                              ),
                              _buildParameterChip(
                                'Demleme Süresi',
                                '${parameters['brewTime'] ?? 'Belirtilmemiş'} sn',
                              ),
                              _buildParameterChip(
                                'Kahve',
                                '${parameters['coffeeAmount'] ?? 'Belirtilmemiş'}g',
                              ),
                              _buildParameterChip(
                                'Su',
                                '${parameters['waterAmount'] ?? 'Belirtilmemiş'}ml',
                              ),
                            ],
                          )
                        else
                          const Text('Parametre bilgisi yok'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildParameterChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.brown[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.brown[900],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String recipeId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tarifi Sil'),
          content: const Text('Bu tarifi silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Sil',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteRecipe(recipeId);
              },
            ),
          ],
        );
      },
    );
  }
}
