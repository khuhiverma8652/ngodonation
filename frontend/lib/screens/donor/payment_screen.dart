// lib/screens/donor/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> campaign;

  const PaymentScreen({required this.campaign, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // 🔥 START PAYMENT
  Future<void> _startPayment() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    try {
      // 1. Create Order on Backend
      final orderResponse = await ApiService.createPaymentOrder(
        campaignId: widget.campaign['_id'],
        amount: amount,
      );

      if (orderResponse['success'] == true) {
        var options = {
          'key': 'rzp_test_SEtUySNeysQ2et', // Should ideally come from backend
          'amount': orderResponse['amount'], // already in paise from backend
          'name': widget.campaign['title'],
          'description': 'Donation',
          'order_id': orderResponse['orderId'],
          'prefill': {
            'contact': '9999999999',
            'email': 'test@email.com',
          }
        };
        _razorpay.open(options);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Error creating order: ${orderResponse['message']}")));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // ✅ PAYMENT SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amount = double.parse(_amountController.text);

    // 2. Verify Payment on Backend
    final verifyResponse = await ApiService.verifyPayment(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
      campaignId: widget.campaign['_id'],
      amount: amount,
    );

    if (verifyResponse['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation Successful 🎉")),
      );
      Navigator.pop(context); // Go back after success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Verification Failed: ${verifyResponse['message']}")),
      );
    }
  }

  // ❌ PAYMENT FAILED
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${response.message}")));
  }

  // ℹ️ EXTERNAL WALLET
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donate Money")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.campaign['title'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Enter Donation Amount"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startPayment,
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
