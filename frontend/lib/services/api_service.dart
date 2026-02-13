import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> _headers({bool auth = false}) {
    final h = {'Content-Type': 'application/json'};
    if (auth && _token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // ================= AUTH =================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? ngoName,
    String? ngoAddress,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          'ngoName': ngoName,
          'ngoAddress': ngoAddress,
        }),
      );
      return jsonDecode(r.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ✅ FIXED: role parameter INCLUDED
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(r.body);
      if (data['success'] == true && data['data']?['token'] != null) {
        setToken(data['data']['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );
      return jsonDecode(r.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resendOTP({
    required String email,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: _headers(),
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(r.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final r = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  // ================= CAMPAIGNS =================

  static Future<Map<String, dynamic>> getCampaigns() async {
    final r = await http.get(
      Uri.parse('$baseUrl/campaigns'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getNearbyCampaigns({
    required double longitude,
    required double latitude,
    int maxDistance = 50000,
    String? category,
  }) async {
    print("TOKEN: $_token");

    String url =
        '$baseUrl/campaigns/nearby?longitude=$longitude&latitude=$latitude&maxDistance=$maxDistance';

    if (category != null && category != 'All') {
      url += '&category=$category';
    }

    final r = await http.get(
      Uri.parse(url),
      headers: _headers(auth: true), // ✅ FIXED
    );

    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getMapCampaigns({
    required double longitude,
    required double latitude,
    int maxDistance = 100000,
    String? category,
  }) async {
    String url =
        '$baseUrl/campaigns/map?longitude=$longitude&latitude=$latitude&maxDistance=$maxDistance';
    if (category != null && category != 'All') {
      url += '&category=$category';
    }
    final r = await http.get(
      Uri.parse(url),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getTodayCampaigns({
    required double longitude,
    required double latitude,
    String? category,
  }) async {
    String url =
        '$baseUrl/campaigns/today?longitude=$longitude&latitude=$latitude';
    if (category != null && category != 'All') {
      url += '&category=$category';
    }
    final r = await http.get(
      Uri.parse(url),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getDonationNeeds({
    required double longitude,
    required double latitude,
    String? category,
  }) async {
    String url =
        '$baseUrl/campaigns/needs?longitude=$longitude&latitude=$latitude';
    if (category != null && category != 'All') {
      url += '&category=$category';
    }
    final r = await http.get(
      Uri.parse(url),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> createCampaign(
    Map<String, dynamic> data,
  ) async {
    print("API CALLING: $baseUrl/campaigns"); // 👈 ADD THIS LINE

    final r = await http.post(
      Uri.parse('$baseUrl/campaigns'),
      headers: _headers(auth: true),
      body: jsonEncode(data),
    );

    print("STATUS CODE: ${r.statusCode}");
    print("RESPONSE BODY: ${r.body}");
    return jsonDecode(r.body);
  }

  // ================= VOLUNTEER =================

  static Future<Map<String, dynamic>> joinVolunteer(String campaignId) async {
    final r = await http.post(
      Uri.parse('$baseUrl/volunteer/join'),
      headers: _headers(auth: true),
      body: jsonEncode({'campaignId': campaignId}),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getVolunteerProgress() async {
    final r = await http.get(
      Uri.parse('$baseUrl/volunteer/progress'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getNGODashboard() async {
    final r = await http.get(
      Uri.parse('$baseUrl/ngo/dashboard/stats'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  // ================= ADMIN =================

  static Future<Map<String, dynamic>> getAdminStats() async {
    final r = await http.get(
      Uri.parse('$baseUrl/admin/stats'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getPendingCampaigns() async {
    final r = await http.get(
      Uri.parse('$baseUrl/admin/campaigns/pending'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> updateCampaignStatus(
    String campaignId,
    String status, {
    String? reason,
  }) async {
    final r = await http.put(
      Uri.parse('$baseUrl/admin/campaigns/$campaignId/status'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'status': status,
        'reason': reason,
      }),
    );
    return jsonDecode(r.body);
  }

//=============create donation===========
  static Future<Map<String, dynamic>> createDonation(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/donations/create'),
      headers: _headers(auth: true),
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPaymentOrder({
    required String campaignId,
    required double amount,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/payments/create-order'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'campaignId': campaignId,
        'amount': amount,
      }),
    );

    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String campaignId,
    required double amount,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/payments/verify'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'campaignId': campaignId,
        'amount': amount,
      }),
    );

    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getImpact() async {
    final r = await http.get(
      Uri.parse('$baseUrl/donations/impact'),
      headers: _headers(auth: true),
    );
    return jsonDecode(r.body);
  }
}
