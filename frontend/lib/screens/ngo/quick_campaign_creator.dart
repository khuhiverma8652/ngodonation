import 'package:flutter/material.dart';
import 'package:ngo_donation_app/services/api_service.dart';

class QuickCampaignCreator extends StatefulWidget {
  const QuickCampaignCreator({super.key});

  @override
  State<QuickCampaignCreator> createState() => _QuickCampaignCreatorState();
}

class _QuickCampaignCreatorState extends State<QuickCampaignCreator> {
final TextEditingController _whyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _areaController = TextEditingController();
  
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;


  final List<String> _categories = ['Food', 'Medical', 'Education', 'Emergency'];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
print("TITLE: ${_titleController.text}");
print("AREA: ${_areaController.text}");
print("CATEGORY: $_selectedCategory");
print("TARGET: ${_targetController.text}");
print("WHY: ${_whyController.text}");
print("DATE: $_selectedDate");

final campaignData = {
  "title": _titleController.text,
  "area": _areaController.text,
  "pincode": "110001", // TEMP
  "category": _selectedCategory,
  "targetAmount": double.tryParse(_targetController.text) ?? 0,
  "whyMatters": _whyController.text,

  "longitude": 77.2090,   // TEMP
  "latitude": 28.6139,    // TEMP

  "startDate": DateTime.now().toIso8601String(),
  "endDate": DateTime.now().add(const Duration(days: 7)).toIso8601String(),
};
       print("Calling: ${ApiService.baseUrl}/campaigns/create");

    final response = await ApiService.createCampaign(campaignData);

    if (mounted) {
      setState(() => _isLoading = false);

      if (response['success'] == true) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Campaign Created Successfully")),
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(response['message'] ?? "Something went wrong")),
  );
}

    }
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Create Campaign'),
      backgroundColor: const Color(0xFFFF5252),
      foregroundColor: Colors.white,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Campaign Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Area/Location',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 12),

            ListTile(
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _selectTime,
            ),

            const SizedBox(height: 16),

            // ✅ NEW FIELD ADDED HERE
            TextFormField(
              controller: _whyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Why it matters',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Amount (₹)',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                final amount = double.tryParse(v!);
                if (amount == null || amount <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCampaign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Campaign'),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _areaController.dispose();
    super.dispose();
    _whyController.dispose();
   }
}