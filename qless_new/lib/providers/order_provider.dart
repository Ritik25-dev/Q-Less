import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// --- NESTED ORDER ITEM MODEL ---
class OrderItem {
  final String id;
  final String foodId;
  final String name;
  final double price;
  final String? imageUrl;
  final int quantity;
  final double itemTotal;

  OrderItem({
    required this.id,
    required this.foodId,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.quantity,
    required this.itemTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Safely extract the populated foodId object
    final foodData = json['foodId'] ?? {};

    return OrderItem(
      id: json['_id'] ?? '',
      foodId: foodData['_id'] ?? '',
      name: foodData['name'] ?? 'Unknown Item',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      itemTotal: (json['itemTotal'] ?? 0).toDouble(),
      imageUrl: foodData['pic'] != null && foodData['pic']['url'] != null
          ? foodData['pic']['url']
          : 'https://via.placeholder.com/150',
    );
  }
}

// --- ORDER MODEL ---
class OrderModel {
  final String id;
  final int orderNo;
  final double totalAmount;
  final String status;
  final DateTime date;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.orderNo,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return OrderModel(
      id: json['_id'] ?? 'Unknown ID',
      orderNo: json['orderNo'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      date: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      items: itemsList,
    );
  }
}

// --- ORDER PROVIDER ---
class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  IO.Socket? _socket; //
  bool _socketInitialized = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  // --- SOCKET LOGIC ---
  void initSocket(String userId) {
    print("🚀 INIT SOCKET CALLED");

    _socket = IO.io(
      'http://10.133.121.127:8080', // your IP
      IO.OptionBuilder()
          .setTransports(['websocket']) // required
          .disableAutoConnect() // IMPORTANT
          .setExtraHeaders({
            "Connection": "Upgrade",
            "Upgrade": "websocket",
          }) // 🔥 FIX
          .build(),
    );

    // FORCE CONNECT
    _socket!.connect();

    _socket!.onConnecting((_) {
      print("⏳ CONNECTING...");
    });

    _socket!.onConnect((_) {
      print("✅ SOCKET CONNECTED");
      print("👤 JOINING ROOM: $userId");

      _socket!.emit('joinUserRoom', userId);
    });

    _socket!.onConnectError((err) {
      print("❌ CONNECT ERROR: $err");
    });

    _socket!.onError((err) {
      print("❌ SOCKET ERROR: $err");
    });

    _socket!.onDisconnect((_) {
      print("❌ DISCONNECTED");
    });
  }

  void _handleOrderUpdate(Map<String, dynamic> data) {
    final updatedOrder = OrderModel.fromJson(data);

    // Find the order in the local list and update its status
    int index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners(); // - Refreshes the UI immediately
    }
  }

  // --- API LOGIC ---
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawData = await _apiService.fetchOrders();
      _orders = rawData.map((json) => OrderModel.fromJson(json)).toList();
      _orders.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
