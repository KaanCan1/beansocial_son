import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footerr extends StatelessWidget {
  const Footerr({
    super.key,
    required List children,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Başlatılamadı $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Footer container tüm ekran genişliğini kaplayacak şekilde ayarlandı.
    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF5F0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Wrap(
        spacing: 40.0,
        runSpacing: 20.0,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Sadece Facebook ikonu gösterilecek
          _footerSection(
            title: 'Bizi Takip Edin',
            children: [
              Row(
                children: [
                  _socialIcon('https://facebook.com'),
                ],
              ),
            ],
          ),
          _footerSection(
            title: 'Sayfalar',
            children: [
              _footerLink('Anasayfa', 'https://google.com'),
              _footerLink('Anketler', 'https://google.com'),
              _footerLink('Kahveler ve Daha Fazlası', 'https://google.com'),
              _footerLink('Hakkımızda', 'https://google.com'),
            ],
          ),
          _footerSection(
            title: 'Kurumsal',
            children: [
              _footerLink('Çerez Politikası', 'https://google.com'),
              _footerLink('Aydınlatma Metni', 'https://google.com'),
              _footerLink('Veri Saklama Politikası', 'https://google.com'),
            ],
          ),
          _footerSection(
            title: 'Bize Ulaşın',
            children: const [
              Text(
                'Tokat Gaziosmanpaşa Üniversitesi\nTaşlıçiftlik Kampüsü, 60250 Tokat / TÜRKİYE',
                style: FontSizeFooter.footerSize,
              ),
              SizedBox(height: 8),
              InkWell(
                child: Text(
                  'Mail Gönderin!',
                  style: FontSizeFooter.headerSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerSection(
      {required String title, required List<Widget> children}) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FontSizeFooter.headerSize),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _footerLink(String text, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(text, style: FontSizeFooter.footerSize),
      ),
    );
  }

  // Flutter'ın kendi Material Icons paketinden Facebook ikonu kullanılıyor.
  Widget _socialIcon(String url) {
    return IconButton(
      onPressed: () => _launchURL(url),
      icon: const Icon(Icons.facebook, size: 20, color: Colors.brown),
    );
  }
}

class FontSizeFooter {
  static const TextStyle footerSize = TextStyle(
    fontSize: 13,
    color: Colors.brown,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle headerSize = TextStyle(
    fontSize: 15,
    color: Colors.brown,
    fontWeight: FontWeight.w600,
  );
}
