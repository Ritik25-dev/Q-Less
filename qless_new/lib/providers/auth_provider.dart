import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userName;
  String? _userId; // Added this field
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get userName => _userName;

  // Getter for the userId so OrderProvider can access it
  String? get userId => _userId;

  // Load token and userId on startup to persist the session
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('token')) {
      _token = prefs.getString('token');
      _userName = prefs.getString('userName');
      _userId = prefs.getString('userId');
    }

    _isInitialized = true;
    notifyListeners();
  }

  // 1. REGISTER
  Future<void> register(
      String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. VERIFY OTP
  Future<void> verifyOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/verifyOtp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 3. LOGIN
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper function to save token and userId
  Future<void> _saveAuthData(Map<String, dynamic> responseData) async {
    _token = responseData['token'];
    // Extracting name and _id from the user object sent by your backend
    _userName = responseData['user']['name'];
    _userId = responseData['user']['id'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userName', _userName!);
    await prefs.setString('userId', _userId!); // Save userId for auto-login
  }

  // LOGOUT
  void logout() async {
    _token = null;
    _userName = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
