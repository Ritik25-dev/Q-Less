import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
// Add this import for sockets
import 'package:socket_io_client/socket_io_client.dart' as IO;

class FoodProvider with ChangeNotifier {
  List<FoodItem> _menu = [];
  bool _isLoading = true;
  String? _errorMessage;

  late IO.Socket socket; // Define the socket

  List<FoodItem> get menu => _menu;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  FoodProvider() {
    _initSocket(); // Initialize socket when provider is created
  }

  void _initSocket() {
    // Replace with your actual backend IP
    socket = IO.io('http://10.133.121.127:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Listen for real-time stock updates from your Node backend
    socket.on('foodStockUpdated', (data) {
      // Expecting data to look like: { id: "123", isAvailable: false }
      final foodIndex = _menu.indexWhere((item) => item.id == data['id']);
      if (foodIndex != -1) {
        // Update the specific item in the local list
        _menu[foodIndex].isAvailable = data['isAvailable'];
        notifyListeners(); // This tells the UI to INSTANTLY redraw that one card!
      }
    });
  }

  // Your existing loadMenu function
  Future<void> loadMenu() async {
    print('🟢 UI requested loadMenu()');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menu = await _apiService.fetchMenu();
      print('🟢 SUCCESS: ${_menu.length} items loaded into state.');
    } catch (e) {
      _errorMessage = e.toString();
      print('🔴 PROVIDER ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
