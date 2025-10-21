
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/content_item.dart';

class HiveService {
  static late Box<ContentItem> contentBox;
  static late Box progressBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ContentItemAdapter());
    contentBox = await Hive.openBox<ContentItem>('contentBox');
    
    await _loadFromJsonIfEmpty();
  }

  
  static Future<void> _loadFromJsonIfEmpty() async {
    if (contentBox.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/lessons.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final u = Uuid();

    for (final pair in map.keys) {
      final pairObj = map[pair] as Map<String, dynamic>;

      
      for (final key in pairObj.keys) {
        final list = pairObj[key] as List<dynamic>? ?? [];

        String type;
        if (key.toLowerCase().contains('vocab')) {
          type = 'vocabulary';
        } else if (key.toLowerCase().contains('phrase')) {
          type = 'phrase';
        } else if (key.toLowerCase().contains('sentence')) {
          type = 'sentence';
        } else {
          continue; 
        }

        for (final e in list) {
          final obj = e as Map<String, dynamic>;
          final item = ContentItem(
            id: u.v4(),
            pair: pair,
            type: type,
            text: obj['text'] ?? obj['word'] ?? '',
            translation: obj['translation'] ?? '',
            example: obj['example'] ?? '',
          );
          await contentBox.put(item.id, item);
        }
      }
    }
  }

  // queries
  static List<String> getPairs() {
    final pairs = contentBox.values.map((e) => e.pair).toSet().toList();
    pairs.sort();
    return pairs;
  }

  static List<ContentItem> getByPairAndType(String pair, String type) =>
      contentBox.values.where((c) => c.pair == pair && c.type == type).toList();

  static List<ContentItem> getAllByPair(String pair) =>
      contentBox.values.where((c) => c.pair == pair).toList();

  static void markSeen(String id) {
    final c = contentBox.get(id);
    if (c != null) {
      c.seen = true;
      contentBox.put(id, c);
    }
  }

  static void toggleLearned(String id) {
    final c = contentBox.get(id);
    if (c != null) {
      c.learned = !c.learned;
      contentBox.put(id, c);
    }
  }

  static List<ContentItem> getSeenOrLearned(String pair) => contentBox.values
      .where((c) => c.pair == pair && (c.seen || c.learned))
      .toList();

  static void saveQuizResult(String pair, int score, int total) {
    final hist = List<Map<String, dynamic>>.from(
      progressBox.get('quiz_history', defaultValue: []) as List<dynamic>,
    );
    hist.add({
      'date': DateTime.now().toIso8601String(),
      'pair': pair,
      'score': score,
      'total': total,
    });
    progressBox.put('quiz_history', hist);
  }

  static List<Map<String, dynamic>> getQuizHistory() {
    final raw =
        progressBox.get('quiz_history', defaultValue: []) as List<dynamic>;
    return List<Map<String, dynamic>>.from(raw);
  }

  static int learnedCount(String pair) =>
      contentBox.values.where((c) => c.pair == pair && c.learned).length;
}
