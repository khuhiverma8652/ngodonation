import 'dart:io';

class ApiConfig {
  static const String physicalDevice =
      "http://10.11.20.94:5000/api"; // 🔁 change IP once

  static const String local =
      "http://localhost:5000/api";

  static String get baseUrl {
    if (Platform.isAndroid) {
      return physicalDevice;
    } else {
      return local;
    }
  }
}
