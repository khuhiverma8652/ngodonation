import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ngo_donation_app/services/api_service.dart';
import 'package:ngo_donation_app/screens/donor/payment_screen.dart';



class NearbyCampaignsScreen extends StatefulWidget {
  const NearbyCampaignsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyCampaignsScreen> createState() => _NearbyCampaignsScreenState();
}

class _NearbyCampaignsScreenState extends State<NearbyCampaignsScreen> {
  List<dynamic> _campaigns = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  Position? _currentPosition;

  final List<String> _categories = ['All', 'Food', 'Medical', 'Education', 'Emergency'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _loadCampaigns(19.0760, 72.8777);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _loadCampaigns(19.0760, 72.8777);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
      _loadCampaigns(position.latitude, position.longitude);
    } catch (e) {
      _loadCampaigns(19.0760, 72.8777);
    }
  }
Future<void> _loadCampaigns(double lat, double lon) async {
  setState(() => _isLoading = true);

  final response = await ApiService.getNearbyCampaigns(
    latitude: lat,
    longitude: lon,
    maxDistance: 50000,
    category: _selectedCategory,
  );

  if (mounted) {
    setState(() {
      print("FULL RESPONSE:");
      print(response);

      _campaigns = response['campaigns'] ?? []; // ✅ THIS IS CORRECT
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Campaigns'),
        backgroundColor: const Color(0xFF6200EE),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = _categories[index];
                        if (_currentPosition != null) {
                          _loadCampaigns(_currentPosition!.latitude, _currentPosition!.longitude);
                        } else {
                          _loadCampaigns(19.0760, 72.8777);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF6200EE),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _campaigns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No campaigns found nearby',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (_currentPosition != null) {
                            await _loadCampaigns(_currentPosition!.latitude, _currentPosition!.longitude);
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _campaigns.length,
                          itemBuilder: (context, index) {
                            final campaign = _campaigns[index];
                            return _CampaignCard(campaign: campaign);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

void _handleDonation(BuildContext context, Map<String, dynamic> campaign) {
  showModalBottomSheet(
    context: context,
    builder: (_) => _DonationOptions(campaign: campaign),
  );
}
}
class _CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final title = campaign['title'] ?? 'Untitled Campaign';
    final category = campaign['category'] ?? 'General';
    final area = campaign['area'] ?? 'Unknown';
    final target = (campaign['targetAmount'] ?? 0).toDouble();
    final raised = (campaign['raisedAmount'] ?? 0).toDouble();
    final distance = campaign['distance']?.toStringAsFixed(1) ?? 'N/A';
    final progress = target > 0 ? (raised / target) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: $title')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: _getCategoryColor(category),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('$distance km', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(area, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹${raised.toStringAsFixed(0)} raised', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('of ₹${target.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
  final state = context.findAncestorStateOfType<_NearbyCampaignsScreenState>();
  state?._handleDonation(context, campaign);
},

                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: const Text('Donate Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'medical':
        return Colors.red;
      case 'education':
        return Colors.blue;
      case 'emergency':
        return Colors.deepOrange;
      default:
        return Colors.purple;
    }
  }
}
class _DonationOptions extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const _DonationOptions({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final category = campaign['category'] ?? 'Item';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "How would you like to donate?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          /// ITEM DONATION
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDonationScreen(
                    campaign: campaign,
                    category: category,
                  ),
                ),
              );
            },
            child: Text("Donate $category"),
          ),

          const SizedBox(height: 10),

          /// MONEY DONATION
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    campaign: campaign,
                  ),
                ),
              );
            },
            child: const Text("Donate Money"),
          ),
        ],
      ),
    );
  }
}
class ItemDonationScreen extends StatefulWidget {
  final Map<String, dynamic> campaign;
  final String category;

  const ItemDonationScreen({
    required this.campaign,
    required this.category,
  });

  @override
  State<ItemDonationScreen> createState() => _ItemDonationScreenState();
}

class _ItemDonationScreenState extends State<ItemDonationScreen> {

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Donate ${widget.category}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: "${widget.category} Type",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                final response = await ApiService.createDonation({
                  "campaignId": widget.campaign['_id'],
                  "donationType": "in-kind",
                  "items": [
                    {
                      "name": _itemController.text,
                      "quantity": int.parse(_quantityController.text),
                      "value": 0
                    }
                  ]
                });

                print("ITEM DONATION RESPONSE: $response");

                if (response['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item Donation Submitted!")),
                  );
                  Navigator.pop(context);
                }

              },
              child: const Text("Submit Donation"),
            ),
          ],
        ),
      ),
    );
  }
}
