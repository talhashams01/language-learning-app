
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/content_item.dart';
import '../services/hive_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late String pair;
  List<ContentItem> pool = [];
  List<_Q> questions = [];
  int current = 0;
  int score = 0;
  bool answered = false;
  int selectedIdx = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    pair = args?['pair'] ?? 'en-ur';
    _preparePool();
    _generateQuestions();
  }

  void _preparePool() {
    pool = HiveService.getAllByPair(pair);
    
    pool = pool.toList();
  }

 
  void _generateQuestions({int count = 8}) {
    final rand = Random();
    final preferred = pool.where((p) => p.seen || p.learned).toList();
    final source = preferred.isNotEmpty ? preferred : pool;
    final selected = List<ContentItem>.from(source)..shuffle(rand);
    questions.clear();

    bool isForward = pair.startsWith('en'); // ✅ English → Other
    for (var i = 0; i < min(count, selected.length); i++) {
      final correct = selected[i];
      final distractors = pool.where((p) => p.id != correct.id).toList()
        ..shuffle(rand);

      // ✅ Pick options according to direction
      final options = <String>[isForward ? correct.translation : correct.text];
      for (var d in distractors.take(3)) {
        options.add(isForward ? d.translation : d.text);
      }
      options.shuffle(rand);

      final correctIndex = options.indexOf(
        isForward ? correct.translation : correct.text,
      );

      // ✅ Prompt based on direction
      final prompt = isForward ? correct.text : correct.translation;

      questions.add(
        _Q(prompt: prompt, options: options, correctIndex: correctIndex),
      );
    }

    if (questions.isEmpty && pool.isNotEmpty) {
      final c = pool[0];
      final opts = <String>[
        isForward ? c.translation : c.text,
        ...pool
            .where((p) => p.id != c.id)
            .take(3)
            .map((e) => isForward ? e.translation : e.text),
      ];
      opts.shuffle();
      questions.add(
        _Q(
          prompt: isForward ? c.text : c.translation,
          options: opts,
          correctIndex: opts.indexOf(isForward ? c.translation : c.text),
        ),
      );
    }
  }

  void _select(int idx) {
    if (answered) return;
    setState(() {
      answered = true;
      selectedIdx = idx;
    });
    if (idx == questions[current].correctIndex) score++;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (current + 1 < questions.length) {
        setState(() {
          current++;
          answered = false;
          selectedIdx = -1;
        });
      } else {
        HiveService.saveQuizResult(pair, score, questions.length);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Finished'),
            content: Text('Score: $score / ${questions.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty)
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Not enough items')),
      );
    final q = questions[current];
    return Scaffold(
      appBar: AppBar(title: Text('Quiz — ${pair.toUpperCase()}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Question ${current + 1} / ${questions.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(q.prompt, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(q.options.length, (i) {
              final isCorrect = q.correctIndex == i;
              final isSelected = selectedIdx == i;
              Color? bg;
              if (answered) {
                if (isCorrect)
                  bg = Colors.green.shade100;
                else if (isSelected)
                  bg = Colors.red.shade100;
              }
              return GestureDetector(
                onTap: () => _select(i),
                child: Card(
                  color: bg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            q.options[i],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (answered && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Text('Score: $score', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Q {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  _Q({required this.prompt, required this.options, required this.correctIndex});
}
