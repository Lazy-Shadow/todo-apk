import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/task_provider.dart';
import 'providers/note_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();
  
  runApp(TodoApp(storage: storage));
}

class TodoApp extends StatelessWidget {
  final StorageService storage;
  
  const TodoApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider(storage)),
        ChangeNotifierProvider(create: (_) => NoteProvider(storage)),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey.shade100,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
