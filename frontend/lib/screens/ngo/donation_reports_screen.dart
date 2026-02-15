import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DonationReportsScreen extends StatefulWidget {
  const DonationReportsScreen({super.key});

  @override
  State<DonationReportsScreen> createState() => _DonationReportsScreenState();
}

class _DonationReportsScreenState extends State<DonationReportsScreen> {
  bool _isLoading = true;
  List<dynamic> _donations = [];

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNGODonations();
      if (response['success']) {
        setState(() {
          _donations = response['donations'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching donations: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Reports'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
              ? const Center(child: Text('No donations found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _donations.length,
                  itemBuilder: (context, index) {
                    final donation = _donations[index];
                    final donor = donation['donorId'] ?? {};
                    final campaign = donation['campaignId'] ?? {};
                    final amount = donation['amount'] ?? 0;
                    final type = donation['donationType'] ?? 'monetary';
                    final isMonetary = type == 'monetary';
                    final isVerified = donation['isVerifiedByNGO'] == true;
                    final dateStr = donation['createdAt'] ?? '';
                    final date = dateStr.isNotEmpty
                        ? DateTime.tryParse(dateStr) ?? DateTime.now()
                        : DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMonetary
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          child: Icon(
                              isMonetary
                                  ? Icons.currency_rupee
                                  : Icons.inventory_2,
                              color: isMonetary ? Colors.green : Colors.orange,
                              size: 18),
                        ),
                        title: Text(donor['name'] ?? 'Anonymous Donor',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('to ${campaign['title'] ?? 'Campaign'}'),
                            Text('${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(fontSize: 11)),
                            if (!isMonetary)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isVerified
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isVerified
                                      ? "RECEIPT GENERATED"
                                      : "AWAITING VERIFICATION",
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isVerified
                                          ? Colors.green.shade900
                                          : Colors.orange.shade900),
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          isMonetary
                              ? '₹$amount'
                              : (isVerified ? 'SHIFTED' : 'ITEMS'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isMonetary
                                ? Colors.green
                                : (isVerified ? Colors.blue : Colors.orange),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
