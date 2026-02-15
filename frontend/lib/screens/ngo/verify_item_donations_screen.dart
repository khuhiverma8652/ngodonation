import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class VerifyItemDonationsScreen extends StatefulWidget {
  const VerifyItemDonationsScreen({super.key});

  @override
  State<VerifyItemDonationsScreen> createState() =>
      _VerifyItemDonationsScreenState();
}

class _VerifyItemDonationsScreenState extends State<VerifyItemDonationsScreen> {
  bool _isLoading = true;
  List<dynamic> _pendingDonations = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingDonations();
  }

  Future<void> _fetchPendingDonations() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNGODonations();
      if (response['success'] == true) {
        final allDonations = response['donations'] ?? [];
        setState(() {
          // 🟢 Logic: MUST NOT BE VERIFIED AND MUST NOT BE FOOD
          _pendingDonations = allDonations.where((d) {
            final type = d['donationType'] ?? 'monetary';
            final isVerified = d['isVerifiedByNGO'] == true;
            final category = d['campaignId']?['category'] ?? '';
            return type == 'in-kind' && !isVerified && category != 'Food';
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Telemetry fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyDonation(String id) async {
    final receiverController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Icon(Icons.verified_user_outlined,
                  size: 60, color: Colors.green),
              const SizedBox(height: 16),
              const Text("Confirm Authorization",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Verify contents and release official receipt?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: receiverController,
                decoration: InputDecoration(
                  labelText: "Receiver's Name",
                  hintText: "NGO Representative",
                  prefixIcon: const Icon(Icons.verified),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Hold",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E2C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Authorize",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final res = await ApiService.verifyDonation(id,
            receiverName: receiverController.text.isNotEmpty
                ? receiverController.text
                : null);
        if (!mounted) return;
        if (res['success'] == true) {
          await _fetchPendingDonations(); // RE-FETCH TO REMOVE FROM LIST
          _showSuccessBottomSheet();
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt, size: 70, color: Colors.green),
            const SizedBox(height: 24),
            const Text("Item Shifted!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
                "Donation moved to SUCCESS LOG. Receipt dispatched via email.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E2C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text("Continue Verification",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Gateway Verification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)))
          : _pendingDonations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _pendingDonations.length,
                  itemBuilder: (context, index) =>
                      _buildDonationCard(_pendingDonations[index], index),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 20),
          const Text("Registry Clear",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text("All pending items have been shifted.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const SizedBox(height: 24),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Monitor",
                  style: TextStyle(color: Color(0xFFE91E63)))),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, int index) {
    final donor = donation['donorId'] ?? {};
    final campaign = donation['campaignId'] ?? {};
    final items = donation['items'] as List? ?? [];
    final date =
        DateTime.tryParse(donation['createdAt'] ?? '') ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text("IN-KIND",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w900,
                              fontSize: 8)),
                    ),
                    Text(DateFormat('dd MMM | hh:mm a').format(date),
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        child: Text(
                            (donation['donorName'] ?? 'D')[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(donation['donorName'] ?? 'Donor',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(campaign['title'] ?? 'Global Support',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text("Package Breakdown:",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: Colors.blueGrey,
                        letterSpacing: 1)),
                const SizedBox(height: 12),
                ...items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.outbox_rounded,
                              size: 14, color: Colors.blueGrey),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(item['name'] ?? 'Item',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))),
                          Text("Qty: ${item['quantity']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue,
                                  fontSize: 12)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _verifyDonation(donation['_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E2C),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 18, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Authorize & Shift Record",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }
}
