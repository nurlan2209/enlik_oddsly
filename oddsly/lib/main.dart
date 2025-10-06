import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oddsly/auth_gate.dart';
import 'firebase_options.dart'; // 1. ДОБАВЬТЕ ЭТОТ ИМПОРТ

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ИЗМЕНИТЕ ЭТУ СТРОКУ
  // Мы передаем конфигурацию для текущей платформы (в вашем случае, для веба)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oddsly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
