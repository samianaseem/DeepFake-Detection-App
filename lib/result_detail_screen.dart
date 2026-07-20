import 'package:flutter/material.dart';
import 'package:final_year_project2025/api.dart';
import 'package:final_year_project2025/historyitemmodelclass.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;
  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Detail'),
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiService.baseUrl}/results/${item.fileName}',
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _row("File Name", item.fileName),
            _row("Status", item.status),
            _row("Type", item.type),
            _row("Date & Time", item.datetime),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          "$label : ${value ?? 'N/A'}",
          style: const TextStyle(fontSize: 16),
        ),
      );
}
