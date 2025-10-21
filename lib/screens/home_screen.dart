
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> pairs = [];
  String selectedPair = 'en-ur';
  final categories = [
    'vocabulary',
    'grammar',
    'phrase',
    'sentence',
    'flashcards',
    'quiz',
   
  ];

  @override
  void initState() {
    super.initState();
    pairs = HiveService.getPairs();
    if (!pairs.contains('en-ur')) pairs.insert(0, 'en-ur');
    selectedPair = pairs.isNotEmpty ? pairs[0] : 'en-ur';
  }

  @override
  Widget build(BuildContext context) {
    pairs = HiveService.getPairs();
    if (!pairs.contains('en-ur')) pairs.insert(0, 'en-ur');
    return Scaffold(
      appBar: AppBar(title: const Text('LinguaPro'),
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Pair:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedPair,
                  items: pairs
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(_labelForPair(p)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedPair = v ?? selectedPair),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/daily',
                    arguments: selectedPair,
                  ),
                  icon: const Icon(Icons.today),
                  label: const Text('Daily (10)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: categories.map((cat) {
                  return CategoryCard(
                    title: cat[0].toUpperCase() + cat.substring(1),
                    subtitle: _subtitle(cat),

                    onTap: () {
                      if (cat == 'flashcards') {
                        Navigator.pushNamed(
                          context,
                          '/flashcards',
                          arguments: {'pair': selectedPair},
                        );
                      } else if (cat == 'quiz') {
                        Navigator.pushNamed(
                          context,
                          '/quiz',
                          arguments: {'pair': selectedPair},
                        );
                      } else if (cat == 'grammar') {
                        Navigator.pushNamed(context, '/grammar');
                      } else {
                        Navigator.pushNamed(
                          context,
                          '/category',
                          arguments: {'pair': selectedPair, 'type': cat},
                        );
                      }
                    },
                    colorStart:
                        Colors.primaries[categories.indexOf(cat) %
                            Colors.primaries.length],
                    colorEnd: Colors
                        .primaries[(categories.indexOf(cat) + 2) %
                            Colors.primaries.length]
                        .shade300,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForPair(String p) {
    switch (p) {
      case 'en-ur':
        return 'English ⇄ Urdu';
      case 'en-ps':
        return 'English ⇄ Pashto';
      case 'en-es':
        return 'English ⇄ Spanish';
      case 'en-fr':
        return 'English ⇄ French';
      case 'ur-en':
        return 'Urdu ⇄ English';
      default:
        return p;
    }
  }

  String _subtitle(String c) {
    switch (c) {
      case 'vocabulary':
        return 'Words & meanings';
      case 'grammar':
        return 'Rules & Structure';
      case 'phrase':
        return 'Common phrases';
      case 'sentence':
        return 'Useful sentences';
      case 'flashcards':
        return 'Practice with audio';
      case 'quiz':
        return 'Test yourself';
      default:
        return '';
    }
  }
}
