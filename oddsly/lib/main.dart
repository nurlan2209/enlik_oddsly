import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oddsly/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Эту строку можно закомментировать, если Firebase используется ТОЛЬКО для Firestore на бэкенде.
  // Но лучше оставить, если планируется использовать другие сервисы Firebase во Flutter.
  await Firebase.initializeApp();
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
      home: const AuthGate(), // ИСПОЛЬЗУЕМ НАШ НОВЫЙ ВИДЖЕТ
    );
  }
}
