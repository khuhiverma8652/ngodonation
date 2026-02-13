import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _impact;

  @override
  void initState() {
    super.initState();
    _loadImpact();
  }

  Future<void> _loadImpact() async {
    final response = await ApiService.getImpact();
    if (response['success']) {
      setState(() {
        _impact = response['impact'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Impact"),
        backgroundColor: const Color(0xFF6200EE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Cards
            Row(
              children: [
                _statCard("₹${_impact?['totalDonated'] ?? 0}", "Total Donated"),
                const SizedBox(width: 10),
                _statCard(
                  "${_impact?['campaignsSupported'] ?? 0}",
                  "Campaigns",
                ),
              ],
            ),
            const SizedBox(height: 10),
            _statCard(_impact?['badge'] ?? "Starter", "Your Badge"),

            const SizedBox(height: 20),

            // Recent Donations
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Donations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            ...(_impact?['donations'] as List).map((d) => _donationTile(d)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6200EE).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _donationTile(Map donation) {
    final campaign = donation['campaignId'] as Map<String, dynamic>?;
    final title = campaign?['title'] ?? "Unknown Campaign";
    final amount = donation['amount'] ?? 0;
    final type = donation['donationType'] ?? "monetary";
    final date = DateTime.tryParse(donation['createdAt'] ?? "")?.toLocal();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: type == "monetary"
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            type == "monetary" ? Icons.payments : Icons.inventory_2,
            color: type == "monetary" ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          type == "monetary" ? "₹$amount Donated" : "Item Donation Submitted",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Text(
          date != null ? "${date.day}/${date.month}/${date.year}" : "Recent",
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
      ),
    );
  }
}
