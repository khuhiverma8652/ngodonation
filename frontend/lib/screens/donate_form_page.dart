import 'package:flutter/material.dart';
import '../services/donation_service.dart';

class DonateForm extends StatefulWidget {
  const DonateForm({super.key});

  @override
  State<DonateForm> createState() => _DonateFormState();
}

class _DonateFormState extends State<DonateForm> {
  final quantity = TextEditingController();
  final description = TextEditingController();
  final address = TextEditingController();

  String itemType = "Clothes";
  bool loading = false;

  void submit() async {
    setState(() => loading = true);

    final ok = await DonationService.createDonation(
      itemType: itemType,
      quantity: quantity.text.trim(),
      description: description.text.trim(),
      address: address.text.trim(),
    );

    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation submitted")),
      );
      quantity.clear();
      description.clear();
      address.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to donate")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            "Make a Donation",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField(
            initialValue: itemType,
            items: const [
              DropdownMenuItem(value: "Clothes", child: Text("Clothes")),
              DropdownMenuItem(value: "Food", child: Text("Food")),
              DropdownMenuItem(value: "Money", child: Text("Money")),
              DropdownMenuItem(value: "Books", child: Text("Books")),
              DropdownMenuItem(value: "Other", child: Text("Other")),
            ],
            onChanged: (v) => setState(() => itemType = v.toString()),
            decoration: const InputDecoration(labelText: "Item Type"),
          ),

          TextField(
            controller: quantity,
            decoration: const InputDecoration(labelText: "Quantity"),
          ),

          TextField(
            controller: description,
            decoration: const InputDecoration(labelText: "Description"),
          ),

          TextField(
            controller: address,
            decoration: const InputDecoration(labelText: "Pickup Address"),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: loading ? null : submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit Donation"),
          ),
        ],
      ),
    );
  }
}
