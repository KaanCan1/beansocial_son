import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ResimYukleme extends StatelessWidget {
  final Function(dynamic) onImageSelected; // Web'de XFile, mobilde File
  final String? currentImageUrl;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double quality;
  final int maxWidth;
  final int maxHeight;

  const ResimYukleme({
    super.key,
    required this.onImageSelected,
    this.currentImageUrl,
    this.size = 120,
    this.backgroundColor = Colors.grey,
    this.iconColor = Colors.white,
    this.quality = 85, // 0-100 arası kalite
    this.maxWidth = 2800, // maksimum genişlik
    this.maxHeight = 2800, // maksimum yükseklik
  });

  Future<void> _pickAndProcessImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          // Web'de File ve sıkıştırma yok, XFile ile devam
          onImageSelected(image);
        } else {
          File imageFile = File(image.path);
          onImageSelected(imageFile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim yükleme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickAndProcessImage(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor.withOpacity(0.1),
          border: Border.all(
            color: backgroundColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            if (currentImageUrl != null)
              ClipOval(
                child: Image.network(
                  currentImageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: iconColor,
                      ),
                    );
                  },
                ),
              )
            else
              Center(
                child: Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: iconColor,
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: size * 0.2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
