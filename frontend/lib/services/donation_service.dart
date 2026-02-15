import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ngo_donation_app/config/api_config.dart';

class DonationService {
  static String get baseUrl => "${ApiConfig.baseUrl}/donations";

  /* CREATE DONATION */
  static Future<bool> createDonation({
    required String itemType,
    required String quantity,
    required String description,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final donorId = prefs.getString("userId");
    final donorEmail = prefs.getString("email");

    if (donorId == null || donorEmail == null) return false;

    final res = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "donorId": donorId,
        "donorName": donorEmail.split("@")[0],
        "donorEmail": donorEmail,
        "itemType": itemType,
        "quantity": quantity,
        "description": description,
        "address": address,
      }),
    );

    return res.statusCode == 201;
  }

  /* GET MY DONATIONS */
  static Future<List> getMyDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final donorId = prefs.getString("userId");

    if (donorId == null) return [];

    final res = await http.get(
      Uri.parse("$baseUrl/donor/$donorId"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }
}
