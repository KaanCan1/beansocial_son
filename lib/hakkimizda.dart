import 'package:beansocial/footerr.dart';
import 'package:beansocial/header.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Hakkimizda extends StatelessWidget {
  const Hakkimizda({super.key});

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
                      'Hakkımızda',
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

              // Introduction card
              _buildSectionCard(
                child: const Text(
                  'BeanSocial, kahve severlerin bir araya gelerek kahve kültürünü keşfettikleri ve deneyimlerini paylaştıkları bir sosyal platformdur. Kahveye tutkusu olanları bir araya getiren bu uygulama, kahve çekirdeklerine ve sosyal etkileşime dair güçlü bir bağ kurmaktadır.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.6,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Section 1
              _buildSectionTitle(
                  '1. Uygulama Fikir Aşaması ve İsim Belirlenmesi'),
              _buildSectionCard(
                child: const Text(
                  '''Öncelikle, uygulama fikrinin temel amacını belirledim: Kahve severlerin etkileşimde bulunabileceği, kahve çeşitlerini keşfederek deneyimlerini paylaşabileceği sosyal bir platform oluşturmak. Fikir aşamasında, kahveye dair tarifler, öneriler ve kullanıcıların deneyimlerini paylaşabileceği bir alan yaratmak istedim. Kahveye tutkusu olanları bir araya getirecek, sosyal bir topluluk sunacak bu uygulama için isim seçeneklerini düşündüm. Kahve kültürüne ve sosyal yapıya uygun bir isim olarak BeanSocial'ı seçtim. Bu isim, hem kahve çekirdeklerine hem de sosyal etkileşime gönderme yaparak uygulamanın ruhunu yansıtıyor.''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Section 2
              _buildSectionTitle('2. Uygulama İçinde Kullanılacak Yapılar'),
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem('• Kişiselleştirilmiş Kahve Önerileri'),
                    const SizedBox(height: 8),
                    const Text(
                      'Kullanıcılar, kahve damak zevkleri ve içim alışkanlıklarına göre kahve önerileri alabilir. Örneğin, sütlü kahve seven bir kullanıcıya latte ve flat white önerileri sunulurken, sert kahvelerden hoşlananlara espresso çeşitleri önerilebilir.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFeatureItem('• Sosyal Paylaşım ve Etkileşim'),
                    const SizedBox(height: 8),
                    const Text(
                      'Kullanıcılar, kahve tariflerini, kendi kahve yapım deneyimlerini ve içtikleri kahvelerin fotoğraflarını paylaşabilir. Diğer kullanıcıların gönderilerine yorum yapabilir, beğeni bırakabilir veya paylaşabilirler.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFeatureItem('• Kahve Bilgi Rehberi'),
                    const SizedBox(height: 8),
                    const Text(
                      'Uygulamada kahve çekirdek türlerinden demleme yöntemlerine, öğütme derecelerinden su sıcaklıklarına kadar kapsamlı bir rehber bulunacak.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFeatureItem('• Kahve Tadım Notları ve Puanlama'),
                    const SizedBox(height: 8),
                    const Text(
                      'Kahve severler, denedikleri kahve çeşitlerine puan verip tadım notları bırakabilir. Asidite, gövde, aroma gibi özellikleri derecelendirebilir ve kahve hakkında notlarını diğer kullanıcılarla paylaşabilir.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFeatureItem(
                        '• Kahve Aboneliği ve Kahve Çekirdeği Önerileri'),
                    const SizedBox(height: 8),
                    const Text(
                      'Kullanıcılar, damak zevklerine göre seçilmiş kahve çekirdeklerinden oluşan haftalık veya aylık abonelik paketlerine kaydolabilir.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Section 3
              _buildSectionTitle('3. Kullanılacak Dil ve Platform Seçimi'),
              _buildSectionCard(
                child: const Text(
                  '''Yaz dönemi stajımda flutter ile proje geliştirme şansı bulmuştum ve dili sevdiğim için bu projeyi de flutter ile geliştirmeye karar verdim. IOS ortamında emülatör üzerinden çalıştırarak test edip uygulamayı o şekilde geliştireceğim.''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Section 4
              _buildSectionTitle(
                  '4. Proje Tasarım Aşaması ve Kodlanmaya Başlanması'),
              _buildSectionCard(
                child: const Text(
                  '''Bu bölümde projemi Figma üzerinden genel hatlarıyla tasarlayıp, kod kısmında ise vscode editörü ile kodlayacağım. Aşağıda tasarıma dair birkaç yaptığım denemeleri ekledim, ileriki zamanlarda tasarımın üzerinden tekrar geçilecek.''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.brown.shade800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeatureItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade700,
      ),
    );
  }
}
