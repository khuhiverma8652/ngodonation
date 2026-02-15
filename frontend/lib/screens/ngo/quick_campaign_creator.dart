import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class QuickCampaignCreator extends StatefulWidget {
  const QuickCampaignCreator({super.key});

  @override
  State<QuickCampaignCreator> createState() => _QuickCampaignCreatorState();
}

class _QuickCampaignCreatorState extends State<QuickCampaignCreator> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _areaController = TextEditingController();
  final _whyController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSuccess = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Medical', 'icon': Icons.medical_services, 'color': Colors.red},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.blue},
    {'name': 'Emergency', 'icon': Icons.warning_rounded, 'color': Colors.amber},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final campaignData = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "area": _areaController.text,
      "pincode": "110001",
      "category": _selectedCategory,
      "targetAmount": double.tryParse(_targetController.text) ?? 0,
      "whyMatters": _whyController.text,
      "longitude": 77.2090,
      "latitude": 28.6139,
      "startDate": DateTime.now().toIso8601String(),
      "endDate": _selectedDate.toIso8601String(),
    };

    try {
      final response = await ApiService.createCampaign(campaignData);
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() => _isSuccess = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? "Error creating campaign")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessView();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                        "Campaign Fundamentals", Icons.auto_awesome),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: _titleController,
                      label: "Campaign Title",
                      hint: "e.g., Winter Food Drive",
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: _descriptionController,
                      label: "Description",
                      hint: "Tell people about your mission...",
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                        "Category & Logistics", Icons.category_outlined),
                    const SizedBox(height: 16),
                    _buildCategorySelector(),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: _areaController,
                      label: "Target Area",
                      hint: "City, Neighborhood",
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                        "Impact & Goals", Icons.volunteer_activism_outlined),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: _whyController,
                      label: "Why it matters",
                      hint: "Describe the positive change...",
                      icon: Icons.favorite_border,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassInput(
                      controller: _targetController,
                      label: _selectedCategory == 'Food'
                          ? "Quantity (kg)"
                          : (_selectedCategory == 'Education'
                              ? "Target Units"
                              : "Target Amount"),
                      hint: _selectedCategory == 'Food'
                          ? "e.g., 500"
                          : (_selectedCategory == 'Education'
                              ? "e.g., 100"
                              : "Enter amount in ₹"),
                      icon: _selectedCategory == 'Food'
                          ? Icons.scale_outlined
                          : (_selectedCategory == 'Education'
                              ? Icons.inventory_2_outlined
                              : Icons.currency_rupee),
                      keyboardType: TextInputType.number,
                      isCurrency: _selectedCategory != 'Food' &&
                          _selectedCategory != 'Education',
                    ),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFFE91E63),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text("Launch Campaign",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.campaign, size: 200, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE91E63)),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436))),
      ],
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isCurrency = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          prefixText: isCurrency ? "₹ " : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          floatingLabelStyle: const TextStyle(
              color: Color(0xFFE91E63), fontWeight: FontWeight.bold),
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Category",
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? cat['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                            color: cat['color'].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat['icon'],
                          color: isSelected ? Colors.white : cat['color']),
                      const SizedBox(height: 4),
                      Text(cat['name'],
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.event_note, color: Color(0xFFE91E63)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("End Date",
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                Text(
                    "${_selectedDate.day} / ${_selectedDate.month} / ${_selectedDate.year}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createCampaign,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFFE91E63).withOpacity(0.4),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Launch Foundation",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green)
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text("Campaign Launched!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                  "Your mission has been submitted for approval. We'll notify you once it's live.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3436),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Back to Dashboard",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _areaController.dispose();
    _whyController.dispose();
    super.dispose();
  }
}
