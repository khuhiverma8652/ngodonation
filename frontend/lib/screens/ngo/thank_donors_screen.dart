import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ThankDonorsScreen extends StatefulWidget {
  const ThankDonorsScreen({super.key});

  @override
  State<ThankDonorsScreen> createState() => _ThankDonorsScreenState();
}

class _ThankDonorsScreenState extends State<ThankDonorsScreen> {
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
          // Only show donations not yet thanked
          _donations = (response['donations'] as List)
              .where((d) => d['isThanked'] != true)
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching donations: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _thankDonor(String donationId) async {
    try {
      final response = await ApiService.thankDonor(donationId);
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you message sent!')),
        );
        _fetchDonations();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thank Donors'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
              ? const Center(child: Text('All donors have been thanked!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _donations.length,
                  itemBuilder: (context, index) {
                    final donation = _donations[index];
                    final donor = donation['donorId'] ?? {};
                    final amount = donation['amount'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(donor['name'] ?? 'Anonymous'),
                        subtitle: Text('Donated ₹$amount'),
                        trailing: ElevatedButton(
                          onPressed: () => _thankDonor(donation['_id']),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white),
                          child: const Text('Thank'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
