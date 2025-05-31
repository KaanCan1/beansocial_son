import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:beansocial/footerr.dart';
import 'package:beansocial/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controllers/home_controller.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _currentIndex = 0;

  final HomeController homeController = Get.put(HomeController());

  final List<String> _imagePaths = [
    'assets/logoBeanSocial.svg',
    'assets/logoBeanSocial.svg',
    'assets/logoBeanSocial.svg',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeController.loadRecipes();
    _changeImage();
  }

  void _changeImage() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _imagePaths.length;
      });
      if (mounted) {
        _changeImage();
      }
    });
  }

  void _sendEmail() async {
    final String name = _nameController.text;
    final String message = _messageController.text;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'kaancan368368@gmail.com', // Hedef mail adresi
      queryParameters: {
        'subject': 'Bize Ulaşın - BeanSocial',
        'body': 'Ad Soyad: $name\n\nAçıklama:\n$message',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta uygulaması açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: SizedBox(
                width: 400,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Agne',
                    color: Colors.black,
                  ),
                  child: Column(
                    children: [
                      Lottie.asset('assets/animasyon.json', height: 150),
                      const SizedBox(height: 20),
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText('BeanSocial'),
                          TypewriterAnimatedText('Kahveler'),
                          TypewriterAnimatedText('Ve Siz'),
                        ],
                        totalRepeatCount: 1,
                        pause: const Duration(milliseconds: 500),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: SvgPicture.asset(
                _imagePaths[_currentIndex],
                key: ValueKey<int>(_currentIndex),
                semanticsLabel: 'Anket',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            // Tarifler bölümü dinamik olarak HomeController'dan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popüler Tarifler',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (homeController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (homeController.error.value != null) {
                      return Text('Hata: \\${homeController.error.value}');
                    }
                    if (homeController.recipes.isEmpty) {
                      return const Text('Hiç tarif bulunamadı.');
                    }
                    return Column(
                      children: homeController.recipes
                          .map((recipe) => Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8)),
                                            color: Colors.brown[50],
                                          ),
                                          child: (recipe['imageUrl'] != null &&
                                                  recipe['imageUrl']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8)),
                                                  child: Image.network(
                                                    recipe['imageUrl'],
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      'assets/coffee_images/kahveDefault.jpeg',
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8)),
                                                  child: Image.asset(
                                                    'assets/coffee_images/kahveDefault.jpeg',
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  recipe['name'] ?? '',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  recipe['description'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Parametreler chip olarak (Map veya List desteği ile)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          bottom: 12,
                                          top: 4),
                                      child: _buildParametersFlexible(
                                          recipe['parameters']),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bize Ulaşın',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir açıklama girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _sendEmail();
                            }
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Gönder'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Footer en sonda
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: const Footerr(children: []),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.brown[700]),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.brown[900],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersFlexible(dynamic parametersRaw) {
    dynamic parameters;
    try {
      parameters =
          parametersRaw is String ? json.decode(parametersRaw) : parametersRaw;
    } catch (e) {
      parameters = null;
    }

    if (parameters is Map) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (parameters['grindSize'] != null)
            _buildParameterChip(
                'Öğütme', parameters['grindSize'].toString(), Icons.grain),
          if (parameters['waterTemp'] != null)
            _buildParameterChip(
                'Sıcaklık', '${parameters['waterTemp']}°C', Icons.thermostat),
          if (parameters['brewTime'] != null)
            _buildParameterChip(
                'Süre', '${parameters['brewTime']} sn', Icons.timer),
          if (parameters['coffeeAmount'] != null)
            _buildParameterChip(
                'Kahve', '${parameters['coffeeAmount']}g', Icons.coffee),
          if (parameters['waterAmount'] != null)
            _buildParameterChip(
                'Su', '${parameters['waterAmount']}ml', Icons.water_drop),
        ],
      );
    } else if (parameters is List) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(parameters.length, (i) {
          return _buildParameterChip(
              'Parametre', parameters[i].toString(), Icons.info);
        }),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
