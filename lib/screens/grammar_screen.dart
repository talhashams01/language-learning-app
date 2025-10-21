import 'package:flutter/material.dart';
import 'package:language_learning_app_intern/models/grammar_topics.dart';
import 'package:language_learning_app_intern/screens/grammar_detail_screen.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Lessons')),
      body: ListView.builder(
        itemCount: grammarTopics.length,
        itemBuilder: (context, index) {
          final topic = grammarTopics[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(topic['title']),
              subtitle: Text(topic['description']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrammarDetailScreen(topic: topic),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}