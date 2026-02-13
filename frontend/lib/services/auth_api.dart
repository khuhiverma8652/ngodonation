import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApi {
  static const String baseUrl = "http://10.0.2.2:5000/api/auth"; 
  // use localhost IP for emulator

  static final storage = FlutterSecureStorage();

  static Future signup(String name, String email, String password, String role) async {
    final res = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role
      }),
    );
    return jsonDecode(res.body);
  }

  static Future verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future login(String email, String password, String role) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      await storage.write(key: "token", value: data["token"]);
    }
    return data;
  }
}
