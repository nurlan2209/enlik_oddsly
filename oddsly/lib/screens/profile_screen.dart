import 'package:flutter/material.dart';
import 'package:oddsly/models/user_model.dart';
import 'package:oddsly/services/api_service.dart';
import 'package:oddsly/auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ИСПРАВЛЕНИЕ: Делаем State публичным для доступа через GlobalKey
  ProfileScreenState createState() => ProfileScreenState();
}

// ИСПРАВЛЕНИЕ: Делаем State публичным
class ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Future<UserModel?>? _userFuture;

  @override
  void initState() {
    super.initState();
    refreshUser(); // Используем публичный метод
  }

  // ИСПРАВЛЕНИЕ: Метод теперь публичный
  Future<void> refreshUser() async {
    setState(() {
      _userFuture = _apiService.getUserProfile();
    });
  }

  void _logout() async {
    await _apiService.clearToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ПРОФИЛЬ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshUser,
        child: FutureBuilder<UserModel?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Ошибка загрузки. Потяните, чтобы обновить.'),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('Нет данных. Потяните, чтобы обновить.'),
              );
            }

            final user = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Текущий баланс',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '₸${user.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
