import 'package:flutter/material.dart';
import 'package:ngo_donation_app/screens/donor/payment_screen.dart';
import 'package:ngo_donation_app/services/payment_service.dart';

class DonationNeedsScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final double targetAmount;
  final double raisedAmount;

  const DonationNeedsScreen({
    Key? key,
    required this.campaignId,
    required this.campaignTitle,
    required this.targetAmount,
    required this.raisedAmount,
  }) : super(key: key);

  @override
  State<DonationNeedsScreen> createState() => _DonationNeedsScreenState();
}

class _DonationNeedsScreenState extends State<DonationNeedsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isAnonymous = false;
  bool _isLoading = false;
  String _selectedAmount = '';

  final List<int> _quickAmounts = [100, 500, 1000, 2000, 5000];

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    if (!PaymentService.isValidAmount(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            campaign: {
              "_id": widget.campaignId,
              "title": widget.campaignTitle,
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.targetAmount > 0
        ? (widget.raisedAmount / widget.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
        backgroundColor: const Color(0xFF6200EE),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Campaign Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.campaignTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${widget.raisedAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text('Raised',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${widget.targetAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text('Goal',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select Amount',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              /// Quick Amount Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amount) {
                  final isSelected =
                      _selectedAmount == amount.toString();
                  return ChoiceChip(
                    label: Text('₹$amount'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAmount = amount.toString();
                        _amountController.text =
                            amount.toString();
                      });
                    },
                    selectedColor: const Color(0xFF6200EE),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// Custom Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Custom Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
                onChanged: (value) =>
                    setState(() => _selectedAmount = ''),
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                value: _isAnonymous,
                onChanged: (value) =>
                    setState(() => _isAnonymous = value ?? false),
                title: const Text('Donate anonymously'),
                controlAffinity:
                    ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              /// Donate Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _processDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF6200EE),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism),
                            SizedBox(width: 8),
                            Text('Donate Now',
                                style:
                                    TextStyle(fontSize: 16)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              /// Secure Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security,
                        color: Colors.blue.shade700,
                        size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Secure payment powered by Razorpay',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}