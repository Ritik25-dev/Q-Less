import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your providers
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart'; // <-- New
// Import your screens
import 'screens/main_dashboard.dart';
import 'screens/auth_screen.dart'; // <-- New
import '../services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()
              ..tryAutoLogin()), // <-- Checks for token on startup
        ChangeNotifierProxyProvider<AuthProvider, FoodProvider>(
          create: (_) => FoodProvider(),
          update: (context, auth, previous) {
            final foodProvider = previous ?? FoodProvider();

            if (auth.isAuthenticated) {
              foodProvider.loadMenu(); // 🔥 only after login
            }

            return foodProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (context, auth, previous) {
            final orderProvider = previous ?? OrderProvider();

            if (auth.userId != null) {
              print("USER ID: ${auth.userId}");
              orderProvider.initSocket(auth.userId!); // 🔥 THIS IS THE KEY FIX
            }

            if (auth.isAuthenticated) {
              orderProvider.fetchOrders();
            }
            return orderProvider;
          },
        ),
      ],
      child: const QLessApp(),
    ),
  );
}

class QLessApp extends StatelessWidget {
  const QLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q-less',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (auth.isAuthenticated) {
            return const MainDashboard();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
