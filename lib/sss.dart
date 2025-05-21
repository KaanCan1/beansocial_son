import 'package:beansocial/footerr.dart';
import 'package:beansocial/header.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SSS extends StatefulWidget {
  const SSS({super.key});

  @override
  State<SSS> createState() => _SSSState();
}

class _SSSState extends State<SSS> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section with animation and title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.brown.shade100,
                      Colors.brown.shade50,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/animasyon.json',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Sıkça Sorulan Sorular',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                        fontFamily: 'Roboto',
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.brown.shade200,
                            offset: const Offset(2, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // FAQ Items
              _buildFAQItem(
                index: 0,
                question: '1. BeanSocial nedir?',
                answer:
                    'BeanSocial, kahve severlerin kahve çeşitlerini keşfedeceği, kahve tariflerini paylaşacağı ve sosyal etkileşimde bulunabileceği bir platformdur.',
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                index: 1,
                question: '2. Uygulama nasıl çalışır?',
                answer:
                    'Uygulama, kullanıcıların kahve tercihlerine göre kişiselleştirilmiş öneriler sunar, sosyal medya benzeri bir ortamda kahve fotoğrafları ve tariflerini paylaşmalarına imkan tanır.',
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                index: 2,
                question: '3. Kahve aboneliği nasıl yapılır?',
                answer:
                    'Kullanıcılar, damak zevklerine uygun kahve çekirdekleri seçebilir ve aylık/haftalık kahve aboneliği paketlerine abone olabilir.',
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                index: 3,
                question: '4. Kahve hakkında nasıl bilgi edinebilirim?',
                answer:
                    'Uygulama içinde, kahve türleri, demleme yöntemleri ve diğer kahve bilgilerine dair kapsamlı bir rehber bulunmaktadır.',
              ),
              const SizedBox(height: 15),
              _buildFAQItem(
                index: 4,
                question: '5. Şifremi unuttum, ne yapmalıyım?',
                answer:
                    'Şifrenizi unuttuysanız, giriş ekranında "Şifremi Unuttum" seçeneğini tıklayarak şifrenizi sıfırlayabilirsiniz.',
              ),
              const SizedBox(height: 30),

              // Footer
              const Footerr(
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(
      {required int index, required String question, required String answer}) {
    final isExpanded = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isExpanded ? Colors.brown.shade200 : Colors.brown.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isExpanded ? Colors.brown.shade300 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isExpanded
                          ? Colors.brown.shade800
                          : Colors.brown.shade700,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.brown.shade600,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.brown.shade200,
              ),
              const SizedBox(height: 15),
              Text(
                answer,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
