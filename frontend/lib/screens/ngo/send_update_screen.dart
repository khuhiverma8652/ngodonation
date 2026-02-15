import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SendUpdateScreen extends StatefulWidget {
  const SendUpdateScreen({super.key});

  @override
  State<SendUpdateScreen> createState() => _SendUpdateScreenState();
}

class _SendUpdateScreenState extends State<SendUpdateScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _campaigns = [];
  String? _selectedCampaignId;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNGODashboard();
      if (response['success']) {
        setState(() {
          _campaigns = response['campaigns'];
          if (_campaigns.isNotEmpty) {
            _selectedCampaignId = _campaigns[0]['_id'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching campaigns: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendUpdate() async {
    if (_selectedCampaignId == null || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a campaign and enter a message')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.sendCampaignUpdate(
        _selectedCampaignId!,
        _messageController.text,
      );
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Campaign Update'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _campaigns.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Campaign',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCampaignId,
                    items: _campaigns.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['_id'],
                        child:
                            Text(c['title'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCampaignId = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Update Message',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share what happened today...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Post Update',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
