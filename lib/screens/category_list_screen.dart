
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/content_item.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});
  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late String pair;
  late String type;
  List<ContentItem> items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    pair = args?['pair'] ?? 'en-ur';
    type = args?['type'] ?? 'vocabulary';
    items = HiveService.getByPairAndType(pair, type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${type[0].toUpperCase()}${type.substring(1)} — ${pair.toUpperCase()}',
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (context, _) => const Divider(),
              itemBuilder: (ctx, i) {
                final it = items[i];
                return ListTile(
                  title: Text(
                    it.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(it.translation),
                  trailing: IconButton(
                    icon: Icon(
                      it.learned
                          ? Icons.check_circle
                          : Icons.bookmark_add_outlined,
                      color: it.learned ? Colors.green : null,
                    ),
                    onPressed: () {
                      HiveService.toggleLearned(it.id);
                      setState(
                        () => items = HiveService.getByPairAndType(pair, type),
                      );
                    },
                  ),
                  onTap: () {
                    HiveService.markSeen(it.id);
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.text,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(it.translation),
                              if (it.example.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Example: ${it.example}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      HiveService.toggleLearned(it.id);
                                      setState(
                                        () => items =
                                            HiveService.getByPairAndType(
                                              pair,
                                              type,
                                            ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      it.learned ? 'Unmark' : 'Mark Learned',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
