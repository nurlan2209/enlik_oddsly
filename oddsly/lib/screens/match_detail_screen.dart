import 'package:flutter/material.dart';
import 'package:oddsly/services/api_service.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handlePlaceBet() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Данные для ставки (для примера)
    final String matchId = "chelsea_vs_leicester";
    final double amount = 200.0;
    final String outcome = "П2 - 1.3";

    // ИСПРАВЛЕНИЕ: Вызываем placeBet без токена, как в новой версии ApiService
    final result = await _apiService.placeBet(matchId, amount, outcome);

    // ИСПРАВЛЕНИЕ: Проверка, что виджет все еще на экране
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.containsKey('betId')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ставка успешно сделана!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white),
        title: const Text(
          'ПРЕМЬЕР ЛИГА',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              const TeamInfoRow(teamName: 'Chelsea', score: 1),
              const SizedBox(height: 10),
              const TeamInfoRow(teamName: 'Leicester C', score: 2),
              const SizedBox(height: 10),
              const Text(
                '49:30',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: const [
                    StatsRow(
                      title: 'Атаки',
                      value1: 27,
                      value2: 12,
                      progress1: 0.7,
                    ),
                    SizedBox(height: 8),
                    StatsRow(
                      title: 'Удары',
                      value1: 6,
                      value2: 16,
                      progress1: 0.3,
                    ),
                    SizedBox(height: 8),
                    StatsRow(
                      title: 'Владение мячем',
                      value1: 70,
                      value2: 30,
                      progress1: 0.7,
                      isPercent: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Результаты матча',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        BetOption(label: '1', value: '1.3'),
                        BetOption(label: 'X', value: '1.3'),
                        BetOption(label: '2', value: '1.3'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handlePlaceBet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Сделать ставку',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TeamInfoRow extends StatelessWidget {
  final String teamName;
  final int score;

  const TeamInfoRow({super.key, required this.teamName, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            teamName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StatsRow extends StatelessWidget {
  final String title;
  final int value1;
  final int value2;
  final double progress1;
  final bool isPercent;

  const StatsRow({
    super.key,
    required this.title,
    required this.value1,
    required this.value2,
    required this.progress1,
    this.isPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ИСПРАВЛЕНИЕ: Убраны лишние скобки {}
            Text(
              '$value1${isPercent ? "%" : ""}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: TextStyle(color: Colors.grey[400])),
            Text(
              '$value2${isPercent ? "%" : ""}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: LinearProgressIndicator(
                  value: progress1,
                  backgroundColor: Colors.grey[700],
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: 1 - progress1,
                backgroundColor: Colors.grey[700],
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BetOption extends StatelessWidget {
  final String label;
  final String value;
  const BetOption({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
