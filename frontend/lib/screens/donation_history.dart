import 'package:flutter/material.dart';
import '../services/donation_service.dart';

class DonationHistory extends StatefulWidget {
  const DonationHistory({super.key});

  @override
  State<DonationHistory> createState() => _DonationHistoryState();
}

class _DonationHistoryState extends State<DonationHistory> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = DonationService.getMyDonations();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snapshot.data as List;

        if (list.isEmpty) {
          return const Center(child: Text("No donations yet"));
        }

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final d = list[i];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text("${d["itemType"]} - ${d["quantity"]}"),
                subtitle: Text(d["address"]),
                trailing: Text(
                  d["status"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
