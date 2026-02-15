import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ngo_donation_app/services/api_service.dart';
import 'package:ngo_donation_app/config/api_config.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> campaign;

  const PaymentScreen({required this.campaign, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  late TabController _tabController;

  // Monetary Controllers
  final TextEditingController _amountController = TextEditingController();

  // Item Controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _itemDescController = TextEditingController();
  String _selectedItemCategory = 'Food';
  String _selectedGateway = 'Razorpay'; // Default
  Map<String, dynamic>? _userProfile;

  bool _isProcessing = false;
  bool _isRecurring = false;
  final primaryColor = const Color(0xFF6200EE);

  final List<Map<String, dynamic>> _itemCategories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Medical', 'icon': Icons.medical_services, 'color': Colors.red},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.blue},
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Colors.green},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true) {
        setState(() {
          _userProfile = response['data'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  // ================= MONETARY LOGIC =================

  Future<void> _startMonetaryPayment() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnackBar("Please enter a valid amount", Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);

    if (_selectedGateway == 'Stripe') {
      _showSnackBar(
          "Stripe integration is coming soon! Please use Razorpay for now.",
          Colors.blue);
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final orderResponse = await ApiService.createPaymentOrder(
        campaignId: widget.campaign['_id'],
        amount: amount,
      );

      if (orderResponse['success'] == true) {
        var options = {
          'key': ApiConfig.razorpayKey,
          'amount': orderResponse['amount'],
          'name': 'NGO Donation',
          'description': widget.campaign['title'],
          'order_id': orderResponse['orderId'],
          'timeout': 300, // 5 minutes
          'retry': {'enabled': true, 'max_count': 1},
          'prefill': {
            'contact': _userProfile?['phone'] ?? '',
            'email': _userProfile?['email'] ?? '',
          },
          'notes': {
            'campaign_id': widget.campaign['_id'],
            'ngo_id': widget.campaign['ngoId']?['_id'] ?? '',
            'type': 'monetary_donation',
            'is_recurring': _isRecurring.toString(),
            'frequency': _isRecurring ? 'monthly' : 'one_time',
          },
          'theme': {'color': '#6200EE'}
        };
        _razorpay.open(options);
      } else {
        throw Exception(orderResponse['message'] ?? "Order creation failed");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);
    try {
      final amount = double.parse(_amountController.text);
      final verifyResponse = await ApiService.verifyPayment(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        campaignId: widget.campaign['_id'],
        amount: amount,
      );

      if (verifyResponse['success'] == true) {
        _showSuccessDialog("Donation Successful!",
            "Thank you for your monetary support. A receipt has been generated.");
      } else {
        throw Exception(verifyResponse['message'] ?? "Verification failed");
      }
    } catch (e) {
      _showSnackBar("Verification Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // ================= IN-KIND LOGIC =================

  Future<void> _submitItemDonation() async {
    if (_itemNameController.text.isEmpty || _itemQtyController.text.isEmpty) {
      _showSnackBar("Please fill in item name and quantity", Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await ApiService.createDonation({
        'campaignId': widget.campaign['_id'],
        'donationType': 'in-kind',
        'items': [
          {
            'name': '[$_selectedItemCategory] ${_itemNameController.text}',
            'quantity': int.tryParse(_itemQtyController.text) ?? 1,
            'description': _itemDescController.text
          }
        ],
        'message': _itemDescController.text,
      });

      if (response['success'] == true) {
        _showSuccessDialog("Donation Recorded!",
            "Your request to donate items has been sent. The NGO will contact you for pickup/drop-off.");
      } else {
        throw Exception(response['message'] ?? "Submission failed");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // ================= UI HELPERS =================

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar("Payment Failed: ${response.message}", Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80)
                .animate()
                .scale(),
            const SizedBox(height: 20),
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit payment screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("BACK TO DASHBOARD",
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
  void dispose() {
    _razorpay.clear();
    _tabController.dispose();
    _amountController.dispose();
    _itemNameController.dispose();
    _itemQtyController.dispose();
    _itemDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Make a Donation",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: "Items"),
            Tab(icon: Icon(Icons.payments), text: "Money"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemsTab(),
          _buildMonetaryTab(),
        ],
      ),
    );
  }

  Widget _buildMonetaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampaignSummaryCard(),
          const SizedBox(height: 32),
          const Text("How much would you like to donate?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(Icons.currency_rupee, size: 32, color: primaryColor),
              hintText: "0",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
          const SizedBox(height: 20),
          _buildAmountPresets(),
          const SizedBox(height: 24),
          // Recurring Donation Checkbox
          Container(
            decoration: BoxDecoration(
              color:
                  _isRecurring ? primaryColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRecurring ? primaryColor : Colors.grey.shade200,
              ),
            ),
            child: CheckboxListTile(
              value: _isRecurring,
              onChanged: (val) => setState(() => _isRecurring = val ?? false),
              activeColor: primaryColor,
              title: const Text(
                "Make this a monthly donation",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "Support this cause continuously. Cancel anytime.",
                style: TextStyle(fontSize: 12),
              ),
              secondary: Icon(
                Icons.repeat,
                color: _isRecurring ? primaryColor : Colors.grey,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Select Payment Gateway",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildGatewaySelector(),
          const SizedBox(height: 48),
          _buildDonateButton(
              onPressed: _startMonetaryPayment,
              label: _selectedGateway == 'Stripe'
                  ? "Pay with Stripe"
                  : "Pay with Razorpay"),
          const SizedBox(height: 24),
          _buildSecurityInfo(),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildItemsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampaignSummaryCard(),
          const SizedBox(height: 32),
          const Text("Select Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCategorySelector(),
          const SizedBox(height: 32),
          const Text("Item Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildItemForm(),
          const SizedBox(height: 48),
          _buildDonateButton(
              onPressed: _submitItemDonation, label: "Submit Item Donation"),
          const SizedBox(height: 40),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildCampaignSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.volunteer_activism, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.campaign['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(widget.campaign['ngoId']?['name'] ?? 'NGO Support',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPresets() {
    final presets = [100, 500, 1000, 2000, 5000];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets
          .map((amt) => InkWell(
                onTap: () =>
                    setState(() => _amountController.text = amt.toString()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _amountController.text == amt.toString()
                        ? primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: _amountController.text == amt.toString()
                            ? primaryColor
                            : Colors.grey.shade200),
                  ),
                  child: Text("₹$amt",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _amountController.text == amt.toString()
                              ? Colors.white
                              : Colors.black87)),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildGatewaySelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGatewayCard(
            'Razorpay',
            'Local & UPI',
            Icons.account_balance_wallet,
            const Color(0xFF2B36BD),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGatewayCard(
            'Stripe',
            'Global & Cards',
            Icons.credit_card,
            const Color(0xFF635BFF),
          ),
        ),
      ],
    );
  }

  Widget _buildGatewayCard(
      String id, String subtitle, IconData icon, Color color) {
    bool isSelected = _selectedGateway == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedGateway = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
            const SizedBox(height: 12),
            Text(
              id,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _itemCategories.length,
        itemBuilder: (context, index) {
          final cat = _itemCategories[index];
          final isSelected = _selectedItemCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedItemCategory = cat['name']),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? cat['color'] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? cat['color'] : Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'],
                      color: isSelected ? Colors.white : cat['color']),
                  const SizedBox(height: 8),
                  Text(cat['name'],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemForm() {
    return Column(
      children: [
        _buildTextField(_itemNameController, "What are you donating?",
            Icons.shopping_basket),
        const SizedBox(height: 16),
        _buildTextField(
            _itemQtyController, "Quantity", Icons.format_list_numbered,
            isNumber: true),
        const SizedBox(height: 16),
        _buildTextField(_itemDescController,
            "Any special instructions? (Optional)", Icons.note,
            maxLines: 3),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDonateButton(
      {required VoidCallback onPressed, required String label}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text("Secured by Razorpay • 256-bit encryption",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
