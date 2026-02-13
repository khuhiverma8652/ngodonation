import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      "http://localhost:5000/api/auth"; // Chrome + Web safe

  /* ================= SIGNUP ================= */
  static Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return res.statusCode == 201;
  }

  /* ================= VERIFY OTP ================= */
  static Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    return res.statusCode == 200;
  }

  /* ================= LOGIN ================= */
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loggedIn", true);
      await prefs.setString("role", data["role"]);
      await prefs.setString("userId", data["userId"]);
      return data;
    }
    return null;
  }

  /* ================= CHECK LOGIN ================= */
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("loggedIn") ?? false;
  }

  /* ================= LOGOUT ================= */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
