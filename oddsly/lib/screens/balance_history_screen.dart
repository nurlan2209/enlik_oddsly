import 'package:flutter/material.dart';

class BalanceHistoryScreen extends StatelessWidget {
  const BalanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        title: const Text('БАЛАНС'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.ac_unit,
              color: Colors.black,
            ), // Placeholder Icon
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            '₸12,580',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          'Пополнение',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Вывод',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                TransactionHistoryItem(
                  title: 'На баланс',
                  amount: '+7 .... 7702',
                  status: 'Выплачено',
                  statusColor: Colors.green,
                  value: '₸ 20 000',
                  date: '05.10.2025   22:00',
                ),
                SizedBox(height: 12),
                TransactionHistoryItem(
                  title: 'На карту',
                  amount: '.... 7702',
                  status: 'Отменено',
                  statusColor: Colors.red,
                  value: '₸ 20 000',
                  date: '05.10.2025   22:00',
                ),
                SizedBox(height: 12),
                TransactionHistoryItem(
                  title: 'На баланс',
                  amount: '+7 .... 7702',
                  status: 'Выплачено',
                  statusColor: Colors.green,
                  value: '₸ 20 000',
                  date: '05.10.2025   22:00',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class TransactionHistoryItem extends StatelessWidget {
  final String title;
  final String amount;
  final String status;
  final Color statusColor;
  final String value;
  final String date;

  const TransactionHistoryItem({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.value,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.blue), // Placeholder
              const SizedBox(width: 8),
              Text(amount, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
