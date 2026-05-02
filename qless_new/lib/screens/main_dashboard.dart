import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart'; // <-- Added import for the Checkout Screen
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

// --- MAIN DASHBOARD (NAVIGATION) ---
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersScreen(),
    // ProfileScreen removed from bottom nav
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.red.shade600,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_rounded), label: 'Order'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded), label: 'History'),
          ],
        ),
      ),
    );
  }
}

// --- ACTUAL HOME SCREEN (STATEFUL FOR FILTERS) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverage'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Q-less',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            color: Colors.black87,
          ),
        ),
        actions: [
          // Profile Avatar is now the button for the profile screen
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: 18,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // LOCAL SEARCH BAR
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search for dishes...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Colors.red),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // CATEGORY FILTER PILLS
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              isSelected ? Colors.red : Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // FOOD LIST WITH CLIENT-SIDE FILTERING
          Expanded(
            child: Consumer<FoodProvider>(
              builder: (context, foodProvider, child) {
                if (foodProvider.isLoading && foodProvider.menu.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.red));
                }

                if (foodProvider.errorMessage != null &&
                    foodProvider.menu.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🚨 ${foodProvider.errorMessage}',
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () => foodProvider.loadMenu(),
                          child: const Text('Try Again',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                }

                // Apply Local Filters
                final filteredMenu = foodProvider.menu.where((food) {
                  final matchesSearch = food.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' ||
                      (food.category != null &&
                          food.category!.toLowerCase() ==
                              _selectedCategory.toLowerCase());
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredMenu.isEmpty) {
                  return Center(
                      child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No dishes found for "$_searchQuery"'
                              : 'No food items available in this category.',
                          style: const TextStyle(fontSize: 16)));
                }

                return RefreshIndicator(
                  color: Colors.red,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await Provider.of<FoodProvider>(context, listen: false)
                        .loadMenu();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredMenu.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                          height: 30,
                          thickness: 1,
                          color: Colors.grey.shade200),
                    ),
                    itemBuilder: (context, index) {
                      return GenerousFoodItem(food: filteredMenu[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // --- THE FLOATING CART BANNER ---
      bottomSheet: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Hide if cart is empty
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cart.items.length} ITEM${cart.items.length > 1 ? 'S' : ''}',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text('View Cart',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_right_rounded,
                            color: Colors.white, size: 30),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // --------------------------------
    );
  }
}

// --- GENEROUS FOOD ITEM WIDGET (WITH EXPLICIT IN-STOCK TAGS) ---
class GenerousFoodItem extends StatelessWidget {
  final dynamic food;

  const GenerousFoodItem({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    bool hasValidImage = food.imageUrl != null &&
        food.imageUrl.toString().trim().isNotEmpty &&
        food.imageUrl.toString().startsWith('http');
    bool isAvailable = food.isAvailable ?? true; // Handles the stock status

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDE: Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.black : Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${food.price}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isAvailable ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  food.category ?? 'Freshly prepared canteen food.',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 13, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // --- IN STOCK / OUT OF STOCK TAG ---
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: isAvailable
                            ? Colors.green.shade200
                            : Colors.red.shade200),
                  ),
                  child: Text(
                    isAvailable ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      color: isAvailable
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // RIGHT SIDE: Safe Image & Floating Button
          SizedBox(
            width: 120,
            height: 140,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Image Holder
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isAvailable ? Colors.transparent : Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: hasValidImage
                          ? Image.network(
                              food.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.fastfood,
                                      color: Colors.grey.shade300, size: 40),
                            )
                          : Icon(Icons.fastfood,
                              color: Colors.grey.shade300, size: 40),
                    ),
                  ),
                ),

                // The ADD Button
                if (isAvailable)
                  Positioned(
                    bottom: 5,
                    child: Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        int quantity = cart.getQuantity(food.id);

                        if (quantity == 0) {
                          return GestureDetector(
                            onTap: () => cart.addItem(food),
                            child: Container(
                              width: 90,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red.shade200, width: 1),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ],
                              ),
                              child: Center(
                                child: Text('ADD',
                                    style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                            ),
                          );
                        }

                        return Container(
                          width: 90,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => cart.removeItem(food.id),
                                child: const Icon(Icons.remove,
                                    color: Colors.red, size: 20),
                              ),
                              Text(quantity.toString(),
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              GestureDetector(
                                onTap: () => cart.addItem(food),
                                child: const Icon(Icons.add,
                                    color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- BEAUTIFUL ORDER HISTORY SCREEN (WITH NAMES & REORDER) ---
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Order History',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5)),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading)
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          if (orderProvider.errorMessage != null)
            return Center(
                child: Text('🚨 ${orderProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red)));
          if (orderProvider.orders.isEmpty)
            return const Center(
                child: Text("You haven't placed any orders yet."));

          return RefreshIndicator(
            color: Colors.red,
            backgroundColor: Colors.white,
            onRefresh: () async => await orderProvider.fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];

                // Formats the item names! (e.g., "2x Pepperoni Feast Pizza")
                String itemsSummary = order.items
                    .map((i) => '${i.quantity}x ${i.name}')
                    .join(', ');
                String formattedDate =
                    '${order.date.day}/${order.date.month}/${order.date.year}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order #${order.orderNo}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(order.status.toUpperCase(),
                                  style: TextStyle(
                                      color: _getStatusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            )
                          ],
                        ),
                        const Divider(height: 24, color: Color(0xFFEEEEEE)),

                        // SHOWING THE ACTUAL NAMES HERE
                        Text(
                          itemsSummary.isEmpty ? 'Unknown Items' : itemsSummary,
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 15,
                              height: 1.4,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(formattedDate,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 18)),

                            // THE REORDER LOGIC
                            OutlinedButton.icon(
                              onPressed: () {
                                final cart = Provider.of<CartProvider>(context,
                                    listen: false);
                                cart.clearCart();

                                // Push the populated data back into the cart model
                                for (var oldItem in order.items) {
                                  cart.addCartItem(CartItem(
                                    id: oldItem.foodId,
                                    name: oldItem.name,
                                    price: oldItem.price,
                                    quantity: oldItem.quantity,
                                    imageUrl: oldItem.imageUrl,
                                  ));
                                }

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Items added to cart!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ));
                              },
                              icon: const Icon(Icons.refresh,
                                  size: 16, color: Colors.red),
                              label: const Text('Reorder',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red.shade200),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- FUNCTIONAL PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely grab the auth provider
    final auth = Provider.of<AuthProvider>(context);

    // Get the first letter of the name for the avatar
    String initial = 'U';
    if (auth.userName != null && auth.userName!.trim().isNotEmpty) {
      initial = auth.userName!.trim()[0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('My Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // User Avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.red.shade50,
                  child: Text(
                    initial,
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // User Name
              Center(
                child: Text(
                  auth.userName ?? 'Foodie',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Ready for your next meal?',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              // LOGOUT BUTTON
              ElevatedButton.icon(
                onPressed: () {
                  // Calls the logout function we wrote in AuthProvider
                  auth.logout();

                  // Pop back to the root. The Gatekeeper in main.dart
                  // will see the token is gone and show the Login screen!
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
