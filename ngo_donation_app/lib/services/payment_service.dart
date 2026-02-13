import 'package:ngo_donation_app/services/api_service.dart';

class PaymentService {

  // Validate amount
  static bool isValidAmount(double amount) {
    return amount > 0;
  }

  // Create donation record AFTER successful payment
  static Future<Map<String, dynamic>> createDonationRecord({
    required String campaignId,
    required double amount,
    required String name,
    required String email,
    required String phone,
    required String transactionId,   // ✅ IMPORTANT
  }) async {
    try {
      final response = await ApiService.createDonation({
        "campaignId": campaignId,
        "amount": amount,
        "paymentMethod": "razorpay",
        "transactionId": transactionId, // ✅ Razorpay paymentId
        "donorName": name,
        "donorEmail": email,
        "donorPhone": phone,
        "donationType": "monetary"
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static void dispose() {}
}