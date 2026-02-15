import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use 10.0.2.2 for Android emulator, or your machine's IP for physical device
  static const String physicalDevice = "http://10.0.2.2:5000/api";

  static const String local = "http://localhost:5000/api";

  static String get baseUrl {
    if (kIsWeb) {
      return local;
    }
    // proper platform check that works on all platforms
    if (defaultTargetPlatform == TargetPlatform.android) {
      return physicalDevice;
    }
    return local;
  }

  static const String razorpayKey = "rzp_test_SEtUySNeysQ2et";
}
