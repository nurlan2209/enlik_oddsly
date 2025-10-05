import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:3000';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Connection error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (data.containsKey('token')) {
        await saveToken(data['token']);
      }
      return data;
    } catch (e) {
      return {'message': 'Connection error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> placeBet(
    String matchId,
    double amount,
    String outcome,
  ) async {
    final token = await getToken();
    if (token == null) {
      return {'message': 'User not authenticated.'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'matchId': matchId,
          'amount': amount,
          'outcome': outcome,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Connection error: ${e.toString()}'};
    }
  }

  // ЭТОТ МЕТОД ТЕПЕРЬ ВНУТРИ КЛАССА
  Future<List<dynamic>> getBetHistory() async {
    final token = await getToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/my-bets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}
