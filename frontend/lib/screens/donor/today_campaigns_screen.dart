import 'package:flutter/material.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class TodayCampaignsScreen extends StatefulWidget {
  const TodayCampaignsScreen({super.key});

  @override
  State<TodayCampaignsScreen> createState() => _TodayCampaignsScreenState();
}

class _TodayCampaignsScreenState extends State<TodayCampaignsScreen> {
  List<dynamic> _campaigns = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Food',
    'Medical',
    'Education',
    'Emergency'
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayCampaigns();
  }

  Future<void> _loadTodayCampaigns() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getTodayCampaigns(
      latitude: 19.0760, // Default for now
      longitude: 72.8777,
      category: _selectedCategory,
    );

    setState(() {
      _campaigns = response['campaigns'] ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Campaigns'),
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
                        _loadTodayCampaigns();
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
                            Icon(Icons.today,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No campaigns scheduled for today',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTodayCampaigns,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _campaigns.length,
                          itemBuilder: (context, index) {
                            final campaign = _campaigns[index];
                            return _TodayCampaignCard(campaign: campaign);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TodayCampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const _TodayCampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final title = campaign['title'] ?? 'Untitled Campaign';
    final category = campaign['category'] ?? 'General';
    final area = campaign['area'] ?? 'Unknown';
    final time = campaign['time'] ?? 'TBD';

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(area, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(time, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: const Text('Donate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(category),
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
        return const Color(0xFF6200EE);
    }
  }
}
