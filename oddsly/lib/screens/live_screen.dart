import 'package:flutter/material.dart';
import 'package:oddsly/screens/match_detail_screen.dart';

class LiveScreen extends StatelessWidget {
  final VoidCallback onBetPlaced; // Принимаем колбэк

  const LiveScreen({super.key, required this.onBetPlaced});

  @override
  Widget build(BuildContext context) {
    // ... (весь остальной код до Expanded остается без изменений)
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Row(
          children: const [
            Text(
              '● LIVE',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(width: 16),
            Text(
              'LINE',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск по ивенту, команде',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                SportChip(
                  icon: Icons.sports_soccer,
                  label: 'Футбол',
                  isSelected: true,
                ),
                SizedBox(width: 10),
                SportChip(
                  icon: Icons.sports_basketball,
                  label: 'Баскетбол',
                  isSelected: false,
                ),
                SizedBox(width: 10),
                SportChip(
                  icon: Icons.sports_tennis,
                  label: 'Теннис',
                  isSelected: false,
                ),
                SizedBox(width: 10),
                SportChip(
                  icon: Icons.sports_hockey,
                  label: 'Хоккей',
                  isSelected: false,
                ),
                SizedBox(width: 10),
                SportChip(
                  icon: Icons.sports_volleyball,
                  label: 'Волейбол',
                  isSelected: false,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MatchDetailScreen(
                          onBetPlaced: onBetPlaced,
                        ), // Передаем колбэк дальше
                      ),
                    );
                  },
                  child: const MatchCard(),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MatchDetailScreen(
                          onBetPlaced: onBetPlaced,
                        ), // Передаем колбэк дальше
                      ),
                    );
                  },
                  child: const MatchCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... (классы SportChip, MatchCard, BetButton остаются без изменений)
class SportChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const SportChip({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: isSelected ? Colors.white : Colors.black),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isSelected ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class MatchCard extends StatelessWidget {
  const MatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Премьер лига', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Chelsea',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.shield, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Leicester C',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: const [
                  Text(
                    '1',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: const [Icon(Icons.bar_chart), Text('790')],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.play_arrow_outlined, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('49:30', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: BetButton(text: 'П1 - 12')),
              SizedBox(width: 10),
              Expanded(child: BetButton(text: 'X - 14.2')),
              SizedBox(width: 10),
              Expanded(child: BetButton(text: 'П2 - 1.3')),
            ],
          ),
        ],
      ),
    );
  }
}

class BetButton extends StatelessWidget {
  final String text;
  const BetButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(text),
    );
  }
}
