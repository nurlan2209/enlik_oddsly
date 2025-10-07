// oddsly/lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:oddsly/models/user_model.dart';
import 'package:oddsly/services/api_service.dart';
import 'package:oddsly/auth_gate.dart';
import 'package:oddsly/screens/deposit_screen.dart';
import 'package:oddsly/screens/withdrawal_screen.dart';
import 'package:oddsly/screens/balance_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Future<UserModel?>? _userFuture;

  @override
  void initState() {
    super.initState();
    refreshUser();
  }

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
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Текущий баланс',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₸${user.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const DepositScreen(),
                                  ),
                                );
                                if (result == true) refreshUser();
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Пополнить'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const WithdrawalScreen(),
                                  ),
                                );
                                if (result == true) refreshUser();
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              label: const Text('Вывести'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildMenuTile(
                  icon: Icons.history,
                  title: 'История транзакций',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BalanceHistoryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuTile(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('В разработке')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuTile(
                  icon: Icons.help_outline,
                  title: 'Помощь',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('В разработке')),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
