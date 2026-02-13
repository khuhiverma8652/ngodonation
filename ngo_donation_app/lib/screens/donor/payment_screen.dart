// lib/screens/donor/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> campaign;

  const PaymentScreen({required this.campaign, Key? key}) : super(key: key);

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
  void _startPayment() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    var options = {
      'key': 'rzp_test_SEtUySNeysQ2et',
      'amount': (amount * 100).toInt(), // in paise
      'name': widget.campaign['title'],
      'description': 'Donation',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@email.com',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  // ✅ PAYMENT SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amount = double.parse(_amountController.text);

    final donationResponse =
        await PaymentService.createDonationRecord(
      campaignId: widget.campaign['_id'],
      amount: amount,
      name: "Anonymous",
      email: "anonymous@email.com",
      phone: "9999999999",
      transactionId: response.paymentId!,
    );

    print(donationResponse);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Donation Successful 🎉")));
  }

  // ❌ PAYMENT FAILED
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Payment Failed ❌")));
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