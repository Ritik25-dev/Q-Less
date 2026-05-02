import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class ApiService {
  static const String baseUrl =
      'http://10.133.121.127:8080'; // Change to your exact IP

  // Helper function to get the secure token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper function to build headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token', // Sends the token to Node.js!
    };
  }

  // 1. Fetch Menu
  Future<List<FoodItem>> fetchMenu() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu'),
          headers: await _getHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 2. Place Order (Now uses secure headers)
  Future<void> placeOrder(List<dynamic> cartItems, double totalAmount) async {
    try {
      final List<Map<String, dynamic>> orderItems = cartItems.map((item) {
        return {
          'foodId': item.id,
          'name': item.name,
          'imageUrl': item.imageUrl,
          'quantity': item.quantity,
          'price': item.price,
          'itemTotal': item.price * item.quantity,
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(), // <-- ADDS TOKEN HERE
        body: jsonEncode({
          'items': orderItems,
          'totalAmount': totalAmount,
          'status': 'Pending',
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            'Failed to place order. Server responded with: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while placing order: $e');
    }
  }

  // 3. Fetch Order History (Now uses secure headers)
  Future<List<dynamic>> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(), // <-- ADDS TOKEN HERE
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load orders. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching orders: $e');
    }
  }
}
