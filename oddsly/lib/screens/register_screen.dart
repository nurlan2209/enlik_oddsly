import 'package:flutter/material.dart';
import 'package:oddsly/screens/main_screen.dart';
import 'package:oddsly/services/api_service.dart';
import 'package:oddsly/widgets/custom_button.dart';
import 'package:oddsly/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Валидация
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните email и пароль')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.register(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.containsKey('token')) {
      // Если регистрация возвращает токен, сохраняем и переходим на главный экран
      await _apiService.saveToken(result['token']);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else if (result['message']?.contains('success') == true ||
        result['message']?.contains('успешно') == true) {
      // Если регистрация успешна, но токена нет - переходим на логин
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Регистрация успешна! Войдите в аккаунт')),
      );
      Navigator.of(context).pop();
    } else {
      // Показываем ошибку
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${result['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ВХОД'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Имя',
              hint: 'Josh',
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Фамилия',
              hint: 'Doe',
              controller: _surnameController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email',
              hint: 'gdemoipet@gmail.com',
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              hint: '••••••••••',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: _isLoading ? 'Регистрация...' : 'Зарегистрироваться',
              onPressed: _isLoading ? () {} : _handleRegister,
            ),
            const SizedBox(height: 40),
            const Text('Или'),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Продолжить через Google',
              onPressed: () {
                // TODO: Реализовать Google Sign-In
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Функция в разработке')),
                );
              },
              isPrimary: false,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Уже есть аккаунт?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Войти',
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
