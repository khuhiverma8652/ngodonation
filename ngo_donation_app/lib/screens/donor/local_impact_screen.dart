import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({Key? key}) : super(key: key);

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

            ...(_impact?['donations'] as List)
                .map((d) => _donationTile(d))
                .toList(),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(donation['campaign']['title']),
        subtitle: Text("₹${donation['amount']}"),
        trailing: Text(
          DateTime.parse(donation['createdAt'])
              .toLocal()
              .toString()
              .split(' ')[0],
        ),
      ),
    );
  }
}
