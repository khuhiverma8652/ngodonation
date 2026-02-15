import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class DonationNeedsScreen extends StatefulWidget {
  final String? campaignId;
  final String? campaignTitle;
  final double? targetAmount;
  final double? raisedAmount;
  final String? ngoId;

  const DonationNeedsScreen({
    super.key,
    this.campaignId,
    this.campaignTitle,
    this.targetAmount,
    this.raisedAmount,
    this.ngoId,
  });

  @override
  State<DonationNeedsScreen> createState() => _DonationNeedsScreenState();
}

class _DonationNeedsScreenState extends State<DonationNeedsScreen> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  late Razorpay _razorpay;

  bool _isAnonymous = false;
  bool _isLoading = false;
  bool _isNGOsLoading = true;
  String _selectedAmount = '';
  List<dynamic> _ngos = [];
  String? _selectedNgoId;

  final List<int> _quickAmounts = [100, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _selectedNgoId = widget.ngoId;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchNGOs();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNGOs() async {
    try {
      final response = await ApiService.getNGOList();
      if (response['success'] == true) {
        setState(() {
          _ngos = response['data'] ?? [];
          _isNGOsLoading = false;
          // If no NGO provided, default to first one if available
          if (_selectedNgoId == null && _ngos.isNotEmpty) {
            _selectedNgoId = _ngos[0]['_id'];
          }
        });
      }
    } catch (e) {
      setState(() => _isNGOsLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);

      // Verify payment and create donation record
      final verifyResponse = await ApiService.verifyPayment(
        orderId: response.orderId ?? "",
        paymentId: response.paymentId ?? "",
        signature: response.signature ?? "",
        campaignId: widget.campaignId ??
            "", // If general, this might be empty or a general ID
        amount: amount,
      );

      if (verifyResponse['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(verifyResponse['message'] ?? "Verification failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _processDonation() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (_selectedNgoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an NGO to donate to")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderResponse = await ApiService.createPaymentOrder(
        campaignId: widget.campaignId ??
            "general", // Pass general if no specific campaign
        amount: amount,
      );

      if (orderResponse['success'] == true) {
        var options = {
          'key': 'rzp_test_SEtUySNeysQ2et', // Demo Key
          'amount': orderResponse['amount'],
          'name': 'NGO Donation',
          'description': widget.campaignTitle ?? 'General Donation',
          'order_id': orderResponse['orderId'],
          'prefill': {
            'contact': '9876543210',
            'email': 'donor@example.com',
          },
          'theme': {'color': '#6200EE'}
        };
        _razorpay.open(options);
      } else {
        throw Exception(orderResponse['message'] ?? "Failed to create order");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Thank You!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your donation has been received and will make a real difference.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Done",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6200EE);
    final target = widget.targetAmount ?? 0.0;
    final raised = widget.raisedAmount ?? 0.0;
    final progress = target > 0 ? (raised / target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Make a Donation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign/NGO Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.campaignTitle ?? 'General Donation',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.targetAmount != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${NumberFormat('#,##,###').format(raised)} Raised',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(target)} Goal',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 32),

            // NGO Dropdown
            const Text(
              'Select NGO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isNGOsLoading
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2)))
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedNgoId,
                        isExpanded: true,
                        hint: const Text("Select an NGO"),
                        items: _ngos.map((ngo) {
                          return DropdownMenuItem<String>(
                            value: ngo['_id'],
                            child: Text(ngo['organizationName'] ??
                                ngo['name'] ??
                                'NGO'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedNgoId = val);
                        },
                      ),
                    ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 32),

            const Text(
              'Select Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amt) {
                final isSelected = _selectedAmount == amt.toString();
                return ChoiceChip(
                  label: Text('₹$amt'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAmount = amt.toString();
                      _amountController.text = amt.toString();
                    });
                  },
                  selectedColor: primaryColor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color:
                            isSelected ? primaryColor : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Custom Amount',
                prefixIcon: const Icon(Icons.currency_rupee),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              onChanged: (val) {
                if (_selectedAmount != val) {
                  setState(() => _selectedAmount = '');
                }
              },
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            CheckboxListTile(
              value: _isAnonymous,
              onChanged: (val) => setState(() => _isAnonymous = val ?? false),
              title: const Text('Donate anonymously',
                  style: TextStyle(fontSize: 14)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: primaryColor,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volunteer_activism),
                          SizedBox(width: 8),
                          Text('Donate Now',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ).animate().fadeIn(delay: 500.ms).scale(),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Secure payment powered by Razorpay',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
