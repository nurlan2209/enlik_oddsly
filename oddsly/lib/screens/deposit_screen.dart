// oddsly/lib/screens/deposit_screen.dart

import 'package:flutter/material.dart';
import 'package:oddsly/services/api_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _handleDeposit() async {
    if (_isLoading) return;

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      _showError('Введите корректную сумму');
      return;
    }

    if (amount < 200) {
      _showError('Минимальная сумма пополнения 200₸');
      return;
    }

    if (_cardController.text.isEmpty) {
      _showError('Введите номер карты');
      return;
    }

    if (!_agreedToTerms) {
      _showError('Примите условия использования');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.depositBalance(
      amount,
      'card',
      cardNumber: _cardController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.containsKey('newBalance')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Баланс пополнен! Новый баланс: ₸${result['newBalance'].toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      _showError(result['message'] ?? 'Ошибка пополнения');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
        title: const Text('ПОПОЛНЕНИЕ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.credit_card, color: Colors.white, size: 30),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'С карты',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Комиссия 5%',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.star, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '4567 •••• •••• 7702',
                prefixIcon: const Icon(Icons.credit_card),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Введите сумму',
                prefixText: '₸ ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (val) => setState(() => _agreedToTerms = val!),
                  activeColor: Colors.black,
                ),
                const Expanded(
                  child: Text(
                    'I agree to the terms of use of the "One click pay" services',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDeposit,
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
                        'Пополнить баланс',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
