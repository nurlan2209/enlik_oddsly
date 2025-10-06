import 'package:flutter/material.dart';
import 'package:oddsly/screens/login_screen.dart';
import 'package:oddsly/screens/main_screen.dart'; // ИЗМЕНЕНИЕ
import 'package:oddsly/services/api_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final ApiService _apiService = ApiService();
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    final token = await _apiService.getToken();
    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_token != null) {
      return const MainScreen(); // ИЗМЕНЕНИЕ
    } else {
      return const LoginScreen();
    }
  }
}
