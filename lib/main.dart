
import 'package:flutter/material.dart';
import 'package:language_learning_app_intern/screens/grammar_screen.dart';
import 'package:language_learning_app_intern/screens/lesson_screen.dart';
import 'services/hive_service.dart';
import 'screens/home_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/flashcard_screen.dart';
import 'screens/quiz_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const LinguaProApp());
}

class LinguaProApp extends StatelessWidget {
  const LinguaProApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LinguaPro',
      theme: ThemeData(primarySwatch: Colors.deepPurple, scaffoldBackgroundColor: Colors.grey[50]),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/category': (_) => const CategoryListScreen(),
        '/daily': (_) => const DailyLessonScreen(),
        '/flashcards': (_) => const FlashcardScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/grammar': (_) => const GrammarScreen(),
      },
    );
  }
}