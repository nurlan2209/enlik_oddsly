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
    _betHistoryFuture = _apiService.getBetHistory();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'lost':
        return Colors.red;
      case 'won':
        return Colors.blue;
      case 'sold':
        return Colors.grey;
      default:
        return Colors.black;
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
      body: FutureBuilder<List<dynamic>>(
        future: _betHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('История ставок пуста.'));
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BetHistoryCard extends StatelessWidget {
  final BetHistory bet;
  final Color color;

  const BetHistoryCard({super.key, required this.bet, required this.color});

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
        children: [
          Row(
            children: [
              Text(
                bet.matchId,
                style: const TextStyle(color: Colors.grey),
              ), // Показываем ID матча
              const Spacer(),
              Text(
                bet.status,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ставка: ${bet.amount} ₸',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bet.outcome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
