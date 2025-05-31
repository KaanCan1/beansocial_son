import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/coffee_recipe_controller.dart';
import '../widgets/resim_yukleme.dart';

class CoffeeRecipeForm extends StatefulWidget {
  const CoffeeRecipeForm({super.key});

  @override
  State<CoffeeRecipeForm> createState() => _CoffeeRecipeFormState();
}

class _CoffeeRecipeFormState extends State<CoffeeRecipeForm> {
  final CoffeeRecipeController controller = Get.find<CoffeeRecipeController>();
  final _recipeFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _grindSizeController = TextEditingController();
  final TextEditingController _waterTempController = TextEditingController();
  final TextEditingController _brewTimeController = TextEditingController();
  final TextEditingController _coffeeAmountController = TextEditingController();
  final TextEditingController _waterAmountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _grindSizeController.dispose();
    _waterTempController.dispose();
    _brewTimeController.dispose();
    _coffeeAmountController.dispose();
    _waterAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kahve Tarifi'),
        backgroundColor: Colors.brown[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _recipeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fotoğraf seçici
              Obx(() => ResimYukleme(
                    onImageSelected: (image) {
                      if (kIsWeb) {
                        controller.selectedImagePath.value = image.path;
                      } else {
                        controller.selectedImagePath.value =
                            (image as File).path;
                      }
                    },
                    currentImageUrl: controller.selectedImagePath.value != null
                        ? kIsWeb
                            ? controller.selectedImagePath.value
                            : null
                        : null,
                    size: 200,
                    backgroundColor: Colors.brown,
                    iconColor: Colors.white,
                  )),

              const SizedBox(height: 24),

              // Kahve adı
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Kahve Adı',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kahve adını girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Kahve türü
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Kahve Türü',
                  helperText: 'Örn: Espresso, Filter Coffee, French Press',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kahve türünü girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Hazırlanış açıklaması
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Hazırlanış Açıklaması',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen hazırlanış açıklamasını girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kahve Parametreleri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kahvenizin tekrar yapılabilmesi için gerekli ölçümleri girin',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Öğütme boyutu
              TextFormField(
                controller: _grindSizeController,
                decoration: InputDecoration(
                  labelText: 'Öğütme Boyutu',
                  helperText: 'Örn: İnce, Orta, Kalın',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen öğütme boyutunu girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Su sıcaklığı
              TextFormField(
                controller: _waterTempController,
                decoration: InputDecoration(
                  labelText: 'Su Sıcaklığı (°C)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen su sıcaklığını girin';
                  }
                  final temp = int.tryParse(value);
                  if (temp == null || temp < 0 || temp > 100) {
                    return 'Geçerli bir sıcaklık girin (0-100°C)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Demleme süresi
              TextFormField(
                controller: _brewTimeController,
                decoration: InputDecoration(
                  labelText: 'Demleme Süresi (saniye)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen demleme süresini girin';
                  }
                  final time = int.tryParse(value);
                  if (time == null || time <= 0) {
                    return 'Geçerli bir süre girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Kahve miktarı
              TextFormField(
                controller: _coffeeAmountController,
                decoration: InputDecoration(
                  labelText: 'Kahve Miktarı (g)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kahve miktarını girin';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Geçerli bir miktar girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Su miktarı
              TextFormField(
                controller: _waterAmountController,
                decoration: InputDecoration(
                  labelText: 'Su Miktarı (ml)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen su miktarını girin';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Geçerli bir miktar girin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  if (_recipeFormKey.currentState!.validate()) {
                    try {
                      // Form verilerini kontrol et
                      if (_nameController.text.isEmpty ||
                          _typeController.text.isEmpty ||
                          _descriptionController.text.isEmpty ||
                          _grindSizeController.text.isEmpty ||
                          _waterTempController.text.isEmpty ||
                          _brewTimeController.text.isEmpty ||
                          _coffeeAmountController.text.isEmpty ||
                          _waterAmountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen tüm alanları doldurun'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Sayısal değerleri güvenli bir şekilde parse et
                      final waterTemp = int.tryParse(_waterTempController.text);
                      final brewTime = int.tryParse(_brewTimeController.text);
                      final coffeeAmount =
                          double.tryParse(_coffeeAmountController.text);
                      final waterAmount =
                          int.tryParse(_waterAmountController.text);

                      if (waterTemp == null ||
                          brewTime == null ||
                          coffeeAmount == null ||
                          waterAmount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Lütfen geçerli sayısal değerler girin'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final recipeData = {
                        'name': _nameController.text.trim(),
                        'type': _typeController.text.trim(),
                        'description': _descriptionController.text.trim(),
                        'parameters': {
                          'grindSize': _grindSizeController.text.trim(),
                          'waterTemp': waterTemp,
                          'brewTime': brewTime,
                          'coffeeAmount': coffeeAmount,
                          'waterAmount': waterAmount,
                        },
                      };

                      // Resim dosyasını kontrol et
                      File? imageFile;
                      if (controller.selectedImagePath.value != null &&
                          !kIsWeb) {
                        imageFile = File(controller.selectedImagePath.value!);
                      }

                      // Tarifi kaydet
                      final success =
                          await controller.createRecipe(recipeData, imageFile);

                      if (success) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tarif başarıyla kaydedildi'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context); // Form sayfasını kapat
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(controller.error.value),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Tarif kaydedilirken bir hata oluştu: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tarifi Kaydet',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
