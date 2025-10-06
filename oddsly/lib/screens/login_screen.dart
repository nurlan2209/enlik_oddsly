import 'package:flutter/material.dart';
import 'package:oddsly/screens/main_screen.dart';
import 'package:oddsly/screens/register_screen.dart'; // 1. ДОБАВЛЕН ИМПОРТ
import 'package:oddsly/services/api_service.dart';
import 'package:oddsly/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.containsKey('token')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${result['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ВХОД'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: _isLoading ? 'ВХОД...' : 'Войти',
              onPressed: _isLoading ? () {} : _handleLogin,
            ),
            const SizedBox(height: 40), // Отступ
            // 2. ДОБАВЛЕН БЛОК С КНОПКОЙ РЕГИСТРАЦИИ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Нет аккаунта?'),
                TextButton(
                  onPressed: () {
                    // Переход на экран регистрации
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Зарегистрироваться',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
