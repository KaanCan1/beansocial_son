import 'package:beansocial/footerr.dart';
import 'package:beansocial/header.dart';
import 'package:flutter/material.dart';

class CoffeeProduct {
  final String title;
  final String subtitle;
  final String notes;
  final double intensity;
  final double roast;
  final String weight;
  final double price;
  final double pricePerKg;
  final String imagePath;
  final String story;

  const CoffeeProduct({
    required this.title,
    required this.subtitle,
    required this.notes,
    required this.intensity,
    required this.roast,
    required this.weight,
    required this.price,
    required this.pricePerKg,
    required this.imagePath,
    required this.story,
  });
}

class Kahveler extends StatelessWidget {
  const Kahveler({super.key});

  final List<CoffeeProduct> coffeeProducts = const [
    CoffeeProduct(
      title: '»Kitale Kenya«',
      subtitle: 'Rarität Kahve',
      notes: 'Kırmızı Frenk Üzümü ve Bal',
      intensity: 4.5,
      roast: 3.0,
      weight: '250 g Çekirdek Kahve',
      price: 349.90,
      pricePerKg: 1399.60,
      imagePath: 'assets/coffee_images/kitale_kenya.jpg',
      story:
          'Kenya’nın verimli topraklarında yetişen Kitale Kenya, meyvemsi dokusuyla kahve tutkunlarının gözdesidir. El işçiliğiyle toplanan çekirdekler, titizlikle işlenerek sizlere sunulmaktadır.',
    ),
    CoffeeProduct(
      title: 'Colombia Supremo',
      subtitle: 'Premium Kahve',
      notes: 'Meyvemsi ve Fındıksı Notlar',
      intensity: 3.5,
      roast: 2.5,
      weight: '250 g Çekirdek Kahve',
      price: 299.90,
      pricePerKg: 1199.60,
      imagePath: 'assets/coffee_images/kitale_kenya.jpg',
      story:
          'Kolombiya’nın yüksek dağlarından gelen Supremo, dengeli asiditesi ve zengin aromasıyla ideal bir günlük kahvedir. Her yudumda And dağlarının ferahlığını hissedin.',
    ),
    CoffeeProduct(
      title: 'Ethiopian Yirgacheffe',
      subtitle: 'Specialty Kahve',
      notes: 'Çiçeksi ve Turunçgil Notları',
      intensity: 4.0,
      roast: 2.0,
      weight: '250 g Çekirdek Kahve',
      price: 319.90,
      pricePerKg: 1279.60,
      imagePath: 'assets/coffee_images/kitale_kenya.jpg',
      story:
          'Etiyopya’nın Yirgacheffe bölgesinden gelen bu kahve, çiçeksi aromaları ve canlı turunçgil notalarıyla öne çıkıyor. İnce işçilikle hazırlanan çekirdekler, eşsiz bir tat deneyimi sunuyor.',
    ),
    CoffeeProduct(
      title: 'Brazilian Santos',
      subtitle: 'Classic Kahve',
      notes: 'Fındıksı ve Çikolata Notları',
      intensity: 3.0,
      roast: 2.5,
      weight: '250 g Çekirdek Kahve',
      price: 279.90,
      pricePerKg: 1119.60,
      imagePath: 'assets/coffee_images/kitale_kenya.jpg',
      story:
          'Brezilya’nın Santos bölgesinden gelen bu kahve, yumuşak içimi ve klasik lezzetiyle kahve severlere keyifli anlar sunuyor. Dengeli yapısı ve aromatik dokusu ile öne çıkıyor.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text(
                'Kahve Bilgilendirme Sayfası',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coffeeProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = coffeeProducts[index];
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        int currentPage = 0;
                        PageController pageController = PageController();
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          insetPadding: const EdgeInsets.all(40),
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        product.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 220,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40),
                                              child: PageView.builder(
                                                controller: pageController,
                                                itemCount: 2,
                                                onPageChanged: (index) {
                                                  setState(() {
                                                    currentPage = index;
                                                  });
                                                },
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Image.asset(
                                                        product.imagePath,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              left: 0,
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_back,
                                                    color: Colors.grey),
                                                onPressed: () {
                                                  if (currentPage > 0) {
                                                    pageController.previousPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_forward,
                                                    color: Colors.grey),
                                                onPressed: () {
                                                  if (currentPage < 1) {
                                                    pageController.nextPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    List.generate(2, (index) {
                                                  return Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4),
                                                    width: currentPage == index
                                                        ? 10
                                                        : 8,
                                                    height: currentPage == index
                                                        ? 10
                                                        : 8,
                                                    decoration: BoxDecoration(
                                                      color: currentPage ==
                                                              index
                                                          ? Colors.black87
                                                          : Colors.grey[400],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        product.notes,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        product.story,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildInfoItem(
                                            icon: Icons.terrain,
                                            label: 'Ağırlık',
                                            content: Text(
                                              product.weight,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          _buildInfoItem(
                                            icon: Icons.opacity,
                                            label: 'Yoğunluk',
                                            content: _buildBeanRating(
                                                product.intensity),
                                          ),
                                          _buildInfoItem(
                                            icon: Icons.local_fire_department,
                                            label: 'Kavurma',
                                            content:
                                                _buildBeanRating(product.roast),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        children: [
                                          Text(
                                            '${product.price.toStringAsFixed(2)} TL',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'TL/kg ${product.pricePerKg.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Kapat',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.asset(
                              product.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            product.notes.length > 60
                                ? '${product.notes.substring(0, 60)}...'
                                : product.notes,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Footerr(children: []),
          ],
        ),
      ),
    );
  }

  Widget _buildBeanRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double diff = rating - index;
        if (diff >= 1) {
          return Image.asset(
            'assets/coffee_images/coffee_bean_full.png',
            width: 18,
            height: 18,
          );
        } else if (diff >= 0.5) {
          return Image.asset(
            'assets/coffee_images/coffee_bean_half.png',
            width: 18,
            height: 18,
          );
        } else {
          return Image.asset(
            'assets/coffee_images/coffee_bean_empty.png',
            width: 18,
            height: 18,
          );
        }
      }),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Widget content,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 3),
        content,
      ],
    );
  }
}
