// oddsly/lib/screens/balance_history_screen.dart

import 'package:flutter/material.dart';
import 'package:oddsly/services/api_service.dart';
import 'package:intl/intl.dart';

class BalanceHistoryScreen extends StatefulWidget {
  const BalanceHistoryScreen({super.key});

  @override
  State<BalanceHistoryScreen> createState() => _BalanceHistoryScreenState();
}

class _BalanceHistoryScreenState extends State<BalanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _apiService.getTransactionHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('ИСТОРИЯ ТРАНЗАКЦИЙ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          FutureBuilder(
            future: _apiService.getUserProfile(),
            builder: (context, snapshot) {
              final balance = snapshot.data?.balance ?? 0;
              return Text(
                '₸${balance.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Ошибка загрузки. Потяните, чтобы обновить.'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('История транзакций пуста'));
                }

                final transactions = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadTransactions();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransactionHistoryItem(transaction: transaction),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionHistoryItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionHistoryItem({super.key, required this.transaction});

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Недавно';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (e) {
      return 'Недавно';
    }
  }

  Color _getStatusColor(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return Colors.green;
      case 'withdrawal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTitle(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'Пополнение';
      case 'withdrawal':
        return 'Вывод';
      default:
        return 'Транзакция';
    }
  }

  String _getStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Выполнено';
      case 'pending':
        return 'В обработке';
      case 'failed':
        return 'Отклонено';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = transaction['type'] ?? 'transaction';
    final status = transaction['status'] ?? 'completed';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final cardNumber = transaction['cardNumber'] ?? '';
    final createdAt = transaction['createdAt'];
    final color = _getStatusColor(type);

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
              Text(
                _getTitle(type),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatus(status),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.credit_card, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                cardNumber.isNotEmpty ? cardNumber : '•••• •••• •••• ••••',
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${type.toLowerCase() == 'deposit' ? '+' : '-'}₸${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: type.toLowerCase() == 'deposit'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(createdAt),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
