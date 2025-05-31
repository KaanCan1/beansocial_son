import 'package:flutter/foundation.dart';

class Config {
  static String get baseUrl {
    if (kIsWeb) {
      const port = 3000;
      return 'http://localhost:$port';
    } else {
      throw Exception('This app is only supported on web browsers');
    }
  }

  // Add timeout duration for API calls
  static const Duration timeoutDuration = Duration(seconds: 10);
}
