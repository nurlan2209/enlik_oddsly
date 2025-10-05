import 'package:flutter/material.dart';
import 'package:oddsly/widgets/custom_button.dart';
import 'package:oddsly/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ВХОД'), // По дизайну здесь "ВХОД"
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
            const CustomTextField(label: 'Имя', hint: 'Josh'),
            const SizedBox(height: 20),
            const CustomTextField(label: 'Фамилия', hint: 'Doe'),
            const SizedBox(height: 20),
            const CustomTextField(label: 'Email', hint: 'gdemoipet@gmail.com'),
            const SizedBox(height: 20),
            const CustomTextField(
              label: 'Password',
              hint: '••••••••••',
              isPassword: true,
            ),
            const SizedBox(height: 30),
            CustomButton(text: 'Зарегистрироваться', onPressed: () {}),
            const SizedBox(height: 40),
            const Text('Или'),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Продолжить через Google',
              onPressed: () {},
              isPrimary: false,
              // Вам нужно будет добавить иконку Google в assets
              // icon: Image.asset('assets/images/google_icon.png', height: 24),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Уже есть аккаунт?'),
                TextButton(
                  onPressed: () {},
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
