
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/content_item.dart';
import 'flashcard_screen.dart';

class DailyLessonScreen extends StatefulWidget {
  const DailyLessonScreen({super.key});
  @override
  State<DailyLessonScreen> createState() => _DailyLessonScreenState();
}

class _DailyLessonScreenState extends State<DailyLessonScreen> {
  late String pair;
  List<ContentItem> todays = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as String?;
    pair = arg ?? 'en-ur';
    _prepareDaily();
  }

  void _prepareDaily() {
    final all = HiveService.getAllByPair(pair);
    final unseen = all.where((c) => !c.seen).toList();
    final rand = Random();
    unseen.shuffle(rand);
    final pick = unseen.take(10).toList();
    if (pick.length < 10) {
      final remaining = all.where((c) => !pick.contains(c)).toList()
        ..shuffle(rand);
      for (var e in remaining) {
        pick.add(e);
        if (pick.length >= 10) break;
      }
    }
    todays = pick;
    for (var t in todays) HiveService.markSeen(t.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Lesson')),
      body: todays.isEmpty
          ? const Center(child: Text('No items for today'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: todays.length,
              itemBuilder: (ctx, i) {
                final it = todays[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      it.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(it.translation),
                    trailing: Text(it.type),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(it.text),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.translation),
                            if (it.example.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Example: ${it.example}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FlashcardScreen(words: todays, pair: pair),
          ),
        ),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Practice Flashcards'),
      ),
    );
  }
}
