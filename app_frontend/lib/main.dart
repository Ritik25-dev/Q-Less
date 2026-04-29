import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CanteenProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        ),
        home: const LoginScreen(),
      ),
    ),
  );
}

// --- PROVIDER LOGIC (Only one class now) ---
class CanteenProvider with ChangeNotifier {
  List menu = [];
  List myOrders = [];
  int crowdPercentage = 0;
  bool isLoading = true;
  String currentUserName = "Guest";

  final String baseUrl = "http://10.133.121.127:5000";

  CanteenProvider() {
    fetchMenu();
    initSocket();
  }

  void setUser(String name) {
    currentUserName = name;
    fetchMyOrders();
    notifyListeners();
  }

  void initSocket() {
    try {
      IO.Socket socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      socket.on('crowd_update', (data) {
        crowdPercentage = data['percentage'] ?? 0;
        notifyListeners();
      });

      socket.on('order_status_updated', (_) {
        fetchMyOrders();
      });
    } catch (e) {
      debugPrint("Socket Error: $e");
    }
  }

  Future<void> fetchMenu() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/items"));
      if (response.statusCode == 200) {
        menu = json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Menu Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders() async {
    if (currentUserName == "Guest") return;
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/orders/user/$currentUserName"));
      if (response.statusCode == 200) {
        myOrders = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Order fetch error: $e");
    }
  }

  Future<bool> placeOrder(String itemName, double price) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/orders/place"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "studentName": currentUserName,
          "items": [
            {"name": itemName, "quantity": 1, "price": price}
          ],
          "totalAmount": price,
        }),
      );
      if (response.statusCode == 201) {
        fetchMyOrders();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Place Order Error: $e");
      return false;
    }
  }
}

// --- LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text("Hansraj Smart Order",
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: "First Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: "Phone Number", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // This line connects the UI to the Logic
                  Provider.of<CanteenProvider>(context, listen: false)
                      .setUser(_nameController.text);

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainNavigationHub()));
                },
                child: const Text("Login",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NAVIGATION HUB ---
class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeMenuScreen(),
    const OrdersStatusScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "My Orders"),
        ],
      ),
    );
  }
}

// --- HOME MENU SCREEN ---
class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canteen = Provider.of<CanteenProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          pinned: true,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Text("Hansraj Canteen",
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Live Crowd Status",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text("${canteen.crowdPercentage}% Busy",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: canteen.crowdPercentage / 100,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        canteen.isLoading
            ? const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()))
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => FoodCard(item: canteen.menu[index]),
                    childCount: canteen.menu.length,
                  ),
                ),
              ),
      ],
    );
  }
}

// --- ORDERS STATUS SCREEN ---
class OrdersStatusScreen extends StatelessWidget {
  const OrdersStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canteen = Provider.of<CanteenProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Order History"), centerTitle: true),
      body: canteen.myOrders.isEmpty
          ? const Center(child: Text("No orders placed yet"))
          : ListView.builder(
              itemCount: canteen.myOrders.length,
              itemBuilder: (context, index) {
                final order = canteen.myOrders[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    title: Text(order['items'][0]['name']),
                    subtitle: Text("Total: ₹${order['totalAmount']}"),
                    trailing: Chip(
                      label: Text(order['status'] ?? "Pending"),
                      backgroundColor: order['status'] == "Ready"
                          ? Colors.green[100]
                          : Colors.orange[100],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final dynamic item;
  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final canteen = Provider.of<CanteenProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          const Expanded(
              child: Icon(Icons.fastfood, size: 50, color: Colors.orange)),
          Text(item['name'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("₹${item['price']}"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              bool success = await canteen.placeOrder(
                  item['name'], item['price'].toDouble());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(success
                        ? "Order Placed Successfully!"
                        : "Order Failed")),
              );
            },
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            child: const Text("Order Now"),
          )
        ],
      ),
    );
  }
}
