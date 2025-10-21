import 'package:flutter/material.dart';

class GrammarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> topic;
  const GrammarDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic['description'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text("Examples:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...List.generate(topic['examples'].length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  "• ${topic['examples'][index]}",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}