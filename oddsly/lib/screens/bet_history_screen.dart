import 'package:flutter/material.dart';
import 'package:oddsly/models/bet_history_model.dart';
import 'package:oddsly/services/api_service.dart';

class BetHistoryScreen extends StatefulWidget {
  const BetHistoryScreen({super.key});

  @override
  State<BetHistoryScreen> createState() => _BetHistoryScreenState();
}

class _BetHistoryScreenState extends State<BetHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _betHistoryFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _betHistoryFuture = _apiService.getBetHistory();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'lost':
        return Colors.red;
      case 'won':
        return Colors.blue; // Вы можете выбрать другой цвет для выигрыша
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Активно';
      case 'lost':
        return 'Проиграно';
      case 'won':
        return 'Выиграно';
      default:
        return 'Продано';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        title: const Text('ИСТОРИЯ СТАВОК'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ac_unit, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder<List<dynamic>>(
          future: _betHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text('История ставок пуста. Потяните, чтобы обновить.'),
              );
            }

            final bets = snapshot.data!
                .map((json) => BetHistory.fromJson(json))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bets.length,
              itemBuilder: (context, index) {
                final bet = bets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: BetHistoryCard(
                    bet: bet,
                    color: _getStatusColor(bet.status),
                    statusText: _getStatusText(bet.status),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class BetHistoryCard extends StatelessWidget {
  final BetHistory bet;
  final Color color;
  final String statusText;

  const BetHistoryCard({
    super.key,
    required this.bet,
    required this.color,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Здесь можно будет отображать лигу, когда мы начнем передавать полные данные о матче
              Text(
                'Ставка #${bet.id.substring(0, 6)}', // Показываем часть ID ставки
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                statusText,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Здесь можно будет отображать команды
          Text(
            bet.matchId.replaceAll('_', ' ').replaceAll('vs', ' vs '),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Сумма ставки',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₸ ${bet.amount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bet.outcome,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
