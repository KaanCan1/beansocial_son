import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beansocial/footerr.dart';
import 'package:beansocial/giris_kontrol.dart';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'header.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({super.key, required this.userName});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

enum MenuOption { updateInfo, myCoffees, myRecipes, logout }

class _ProfilePageState extends State<ProfilePage> {
  MenuOption _selected = MenuOption.updateInfo;
  String? _profileImageUrl;
  String? _userName;
  bool _isLoading = true;

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sol menü - Sabit genişlikte
                        SizedBox(
                          width: 260,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.grey[200],
                                            backgroundImage:
                                                _profileImageUrl != null
                                                    ? NetworkImage(
                                                        _profileImageUrl!)
                                                    : null,
                                            child: _profileImageUrl == null
                                                ? Icon(Icons.person,
                                                    size: 50,
                                                    color: Colors.brown[400])
                                                : null,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.brown[700],
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: 20),
                                                onPressed: () {
                                                  setState(() {
                                                    _selected =
                                                        MenuOption.updateInfo;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _userName ?? widget.userName,
                                        style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Kahve Tutkunu',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          color: Colors.brown[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const Divider(height: 32),
                                    ],
                                  ),
                                ),
                                _buildMenuItem(Icons.edit, 'Bilgileri Güncelle',
                                    MenuOption.updateInfo),
                                _buildMenuItem(Icons.local_cafe, 'Kahvelerim',
                                    MenuOption.myCoffees),
                                _buildMenuItem(Icons.receipt_long, 'Tariflerim',
                                    MenuOption.myRecipes),
                                const SizedBox(height: 16),
                                _buildMenuItem(Icons.logout, 'Çıkış Yap',
                                    MenuOption.logout,
                                    isLogout: true),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        // Sağ içerik - Genişleyebilir
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _buildContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Alt footer
                  const Footerr(children: []),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, MenuOption option,
      {bool isLogout = false}) {
    final selected = _selected == option;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? Colors.brown[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: selected ? Colors.brown[700] : Colors.grey[600], size: 22),
        title: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.brown[700] : Colors.grey[800],
          ),
        ),
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          if (isLogout) {
            _onLogout();
          } else {
            setState(() => _selected = option);
          }
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selected) {
      case MenuOption.updateInfo:
        return UpdateInfoSection(userName: widget.userName);
      case MenuOption.myCoffees:
        return const MyCoffeesSection();
      case MenuOption.myRecipes:
        return const MyRecipesSection();
      case MenuOption.logout:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 48, color: Colors.brown[400]),
              const SizedBox(height: 16),
              Text(
                'Çıkış yapmak için menüden devam edin.',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.brown[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Çıkış Yap', style: GoogleFonts.nunito()),
        content: Text('Çıkış yapmak istediğinize emin misiniz?',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: GoogleFonts.nunito())),
          TextButton(
            onPressed: () async {
              // Gerçek çıkış işlemi
              await AuthService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Evet', style: GoogleFonts.nunito()),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse('$_baseUrl/api/auth/user/$userId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        Map<String, dynamic> userData;

        if (decodedData is List && decodedData.isNotEmpty) {
          userData = decodedData[0];
        } else if (decodedData is Map<String, dynamic>) {
          userData = decodedData;
        } else {
          throw Exception('Beklenmeyen veri formatı');
        }

        setState(() {
          _userName = userData['name'] ?? '';
          _profileImageUrl = userData['profileImage'] != null
              ? '$_baseUrl${userData['profileImage']}'
              : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class UpdateInfoSection extends StatefulWidget {
  final String userName;
  const UpdateInfoSection({super.key, required this.userName});

  @override
  State<UpdateInfoSection> createState() => _UpdateInfoSectionState();
}

class _UpdateInfoSectionState extends State<UpdateInfoSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  String? _userId;
  String? _profileImageUrl;
  XFile? _selectedXFile; // Use XFile to be compatible with web
  final _picker = ImagePicker();

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('[_pickImage] Fotoğraf seçme işlemi başlatılıyor...');
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print(
            '[_pickImage] Bir dosya seçildi: ${pickedFile.name}, Tipi: ${pickedFile.mimeType}');
        setState(() {
          _selectedXFile = pickedFile;
        });
        // Dosya seçildikten sonra yükleme işlemini başlat
        await _uploadImage();
      } else {
        print('[_pickImage] Dosya seçimi iptal edildi.');
      }
    } catch (e, stackTrace) {
      print('[_pickImage] Fotoğraf seçilirken bir hata oluştu: $e');
      print('[_pickImage] Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: ${e.toString()}')),
      );
      setState(
          () => _isLoading = false); // Hata durumunda yükleme durumunu kapat
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedXFile == null || _userId == null) {
      print(
          '[_uploadImage] Yüklenecek dosya veya kullanıcı ID numarası yok. Yükleme iptal edildi.');
      setState(
          () => _isLoading = false); // Yükleme yoksa yükleme durumunu kapat
      return;
    }

    print('[_uploadImage] Fotoğraf yükleme işlemi başlatılıyor...');
    setState(() =>
        _isLoading = true); // Yükleme başladığında loading durumunu aktif et

    try {
      // Dosya boyutunu kontrol et
      final fileSize = await _selectedXFile!.length();
      print('[_uploadImage] Dosya boyutu: $fileSize bytes');
      if (fileSize > 5 * 1024 * 1024) {
        // 5MB sınırı
        throw Exception(
            'Dosya boyutu çok büyük. Maksimum 5MB yükleyebilirsiniz.');
      }

      // Dosya türünü kontrol et
      final mimeType = _selectedXFile!.mimeType?.toLowerCase();
      print('[_uploadImage] Dosya MIME tipi: $mimeType');
      if (mimeType == null ||
          ![
            'image/jpeg',
            'image/png',
            'image/gif',
            'image/jpg',
            'image/webp'
          ] // Webp de eklendi
              .contains(mimeType)) {
        throw Exception(
            'Geçersiz dosya türü. Sadece JPEG, PNG, GIF, JPG ve WEBP dosyaları yüklenebilir.');
      }

      // Multipart isteği oluştur
      final uploadUrl = Uri.parse('$_baseUrl/api/auth/upload-profile-image');
      print('[_uploadImage] Yükleme URLsi: $uploadUrl');
      var request = http.MultipartRequest('POST', uploadUrl);

      // Dosyayı ekle
      // Web için XFile'dan bytes oku, mobil için path kullan
      if (kIsWeb) {
        final bytes = await _selectedXFile!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // Backend'de beklenen alan adı
            bytes,
            filename: _selectedXFile!.name,
            contentType: MediaType.parse(mimeType),
          ),
        );
        print('[_uploadImage] Web için dosya byte olarak eklendi.');
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Backend'de beklenen alan adı
            _selectedXFile!.path,
            filename: _selectedXFile!.name,
            contentType: MediaType.parse(mimeType),
          ),
        );
        print('[_uploadImage] Mobil için dosya path olarak eklendi.');
      }

      // Kullanıcı ID'sini ekle
      request.fields['userId'] = _userId!; // Backend'de beklenen alan adı
      print('[_uploadImage] Kullanıcı IDsi eklendi: $_userId');

      // İsteği gönder ve yanıtı bekle
      print('[_uploadImage] İstek gönderiliyor...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Yükleme için timeout süresi artırıldı
        onTimeout: () {
          throw TimeoutException(
              'Sunucuya fotoğraf yükleme zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print('[_uploadImage] Yanıt alındı. Durum kodu: ${response.statusCode}');
      print('[_uploadImage] Yanıt gövdesi: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Sunucudan gelen yeni profil resim URL'sini al ve state'i güncelle
        setState(() {
          _profileImageUrl =
              data['imageUrl'] != null ? '$_baseUrl${data['imageUrl']}' : null;
          _selectedXFile = null; // Yükleme başarılı, seçili dosyayı temizle
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil resmi başarıyla güncellendi')),
        );
        print('[_uploadImage] Fotoğraf başarıyla yüklendi.');
      } else {
        // Sunucudan gelen hata mesajını yakala
        String errorMessage = 'Fotoğraf yüklenirken bir hata oluştu';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Yanıt gövdesi JSON değilse genel hata mesajı kullan
          print(
              '[_uploadImage] Yanıt gövdesi JSON formatında değil: ${response.body}');
        }
        throw Exception(
            'Sunucu hatası: $errorMessage (Durum kodu: ${response.statusCode})');
      }
    } on SocketException catch (e, stackTrace) {
      print('[_uploadImage] SocketException: Sunucuya bağlanılamadı. $e');
      print('[_uploadImage] Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Sunucuya bağlanılamadı. Lütfen sunucunun çalıştığından ve internet bağlantınızın olduğundan emin olun.')),
      );
    } on TimeoutException catch (e, stackTrace) {
      print(
          '[_uploadImage] TimeoutException: Sunucu yanıt vermedi veya yükleme çok uzun sürdü. $e');
      print('[_uploadImage] Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Sunucu yanıt vermedi veya yükleme zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.')),
      );
    } catch (e, stackTrace) {
      // Diğer tüm hatalar için genel yakalama
      print('[_uploadImage] Beklenmeyen bir hata oluştu: $e');
      print('[_uploadImage] Stack trace: $stackTrace');
      String errorMessage = 'Fotoğraf yüklenirken beklenmeyen bir hata oluştu';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      // İşlem tamamlandığında loading durumunu kapat
      setState(() => _isLoading = false);
      print('[_uploadImage] Fotoğraf yükleme işlemi tamamlandı.');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        setState(() {
          _error = 'Kullanıcı bilgileri bulunamadı';
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse('$_baseUrl/api/auth/user/$userId');
      print('Fetching user data from: $url'); // Log the URL

      final response = await http.get(
        url, // Use the logged URL
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        Map<String, dynamic> userData;

        if (decodedData is List && decodedData.isNotEmpty) {
          // If the response is a list, take the first element
          userData = decodedData[0];
        } else if (decodedData is Map<String, dynamic>) {
          // If the response is already a map
          userData = decodedData;
        } else {
          throw Exception('Beklenmeyen veri formatı');
        }

        setState(() {
          _userId = userId;
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _usernameController.text = userData['username'] ?? '';
          // Ensure we have the full URL for the profile image
          _profileImageUrl = userData['profileImage'] != null
              ? '$_baseUrl${userData['profileImage']}'
              : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Kullanıcı bilgileri yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      // Catch error and stack trace
      setState(() {
        _error = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
      print('Error loading user data: $e'); // Log the error
      print('Stack trace: $stackTrace'); // Log the stack trace
    }
  }

  Future<void> _updateUserInfo() async {
    if (_userId == null) return;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/auth/user/$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'username': _usernameController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilgiler başarıyla güncellendi')),
        );
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Güncelleme başarısız';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme başarısız: $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: GoogleFonts.nunito(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(Icons.person, size: 60, color: Colors.brown[400])
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[700],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Bilgileri Güncelle',
              style: GoogleFonts.nunito(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildField('Ad Soyad', _nameController),
          const SizedBox(height: 12),
          _buildField('E-posta', _emailController),
          const SizedBox(height: 12),
          _buildField('Kullanıcı Adı', _usernameController),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _updateUserInfo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Kaydet',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class MyCoffeesSection extends StatelessWidget {
  const MyCoffeesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_cafe, color: Colors.brown[700], size: 28),
            const SizedBox(width: 12),
            Text(
              'Kahvelerim',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: 4, // Örnek veri
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.local_cafe,
                      color: Colors.brown[700], size: 24),
                ),
                title: Text(
                  ['Espresso', 'Latte', 'Cappuccino', 'Americano'][i],
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Son içildi: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyRecipesSection extends StatelessWidget {
  const MyRecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.brown[700], size: 28),
            const SizedBox(width: 12),
            Text(
              'Tariflerim',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: 3, // Örnek veri
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.receipt_long,
                      color: Colors.brown[700], size: 24),
                ),
                title: Text(
                  [
                    'Vanilla Latte Tarifi',
                    'Mocha Tarifi',
                    'Cold Brew Tarifi'
                  ][i],
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Oluşturulma: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.blueAccent),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
