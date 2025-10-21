
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/content_item.dart';
import '../services/hive_service.dart';

class FlashcardScreen extends StatefulWidget {
  final List<ContentItem>? words;
  final String? pair;
  const FlashcardScreen({super.key, this.words, this.pair});
  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<ContentItem> items;
  final FlutterTts _tts = FlutterTts();
  int index = 0;

  @override
  void initState() {
    super.initState();
    items =
        widget.words ??
        (widget.pair != null
            ? HiveService.getAllByPair(widget.pair!)
            : HiveService.getAllByPair('en-ur'));
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(ContentItem it) async {

    final map = {
      'en-ur': 'en-US',
      'en-ps': 'en-US',
      'en-es': 'en-US',
      'en-fr': 'en-US',
      'ur-en': 'ur-PK',
    };
    final langCode = map[it.pair] ?? 'en-US';
    await _tts.setLanguage(langCode);
    await _tts.setPitch(1.0);
    await _tts.speak(it.text);
  }

  void _next() {
    if (index + 1 < items.length) setState(() => index++);
  }

  void _prev() {
    if (index - 1 >= 0) setState(() => index--);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('No items')),
      );
    final it = items[index];
    return Scaffold(
      appBar: AppBar(title: Text('Flashcards ${index + 1}/${items.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          it.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            it.learned
                                ? Icons.check_circle
                                : Icons.bookmark_add_outlined,
                            color: it.learned ? Colors.green : null,
                          ),
                          onPressed: () {
                            HiveService.toggleLearned(it.id);
                            setState(() => {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      it.text,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(it.translation, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),
                    if (it.example.isNotEmpty)
                      Text(
                        it.example,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _prev,
                          icon: const Icon(Icons.chevron_left),
                          iconSize: 36,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => _speak(it),
                          icon: const Icon(Icons.volume_up),
                          iconSize: 30,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _next,
                          icon: const Icon(Icons.chevron_right),
                          iconSize: 36,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                items.shuffle();
                setState(() => index = 0);
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Shuffle'),
            ),
          ],
        ),
      ),
    );
  }
}
