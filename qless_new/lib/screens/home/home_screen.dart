import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q-less Canteen',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // THE DEBUG BUTTON
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red, size: 30),
            onPressed: () {
              // This forces the app to try fetching the data when you tap it
              Provider.of<FoodProvider>(context, listen: false).loadMenu();
            },
          )
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          // 1. If it's loading, show the spinner
          if (foodProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          }

          // 2. IF THERE IS AN ERROR, SHOW IT HUGE ON THE SCREEN
          if (foodProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '🚨 ERROR:\n${foodProvider.errorMessage}',
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 3. If list is empty but no error
          if (foodProvider.menu.isEmpty) {
            return const Center(
                child: Text('No food items found in the database.'));
          }

          // 4. Success! Show the food.
          return ListView.builder(
            itemCount: foodProvider.menu.length,
            itemBuilder: (context, index) {
              final food = foodProvider.menu[index];
              return FoodCard(food: food); // Use your custom widget!
            },
          );
        },
      ),
    );
  }
}

// Reusable Food Card Widget
// Reusable Food Card Widget (CRASH-PROOF VERSION)
// Reusable Food Card Widget (OVERFLOW-PROOF VERSION)
class FoodCard extends StatelessWidget {
  final dynamic food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    // 1. THE SAFETY CHECK: Make sure the URL is actually a valid link!
    String validUrl = 'https://via.placeholder.com/150'; // Default fallback
    if (food.imageUrl != null && food.imageUrl.toString().trim().isNotEmpty) {
      validUrl = food.imageUrl;
    }

    return Container(
      // ADDED MARGIN: This puts space between the cards in your list
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize
            .min, // Tells the column to only take as much space as it needs
        children: [
          // --- THE FIX IS HERE ---
          // Replaced 'Expanded' with 'SizedBox' to give the image a strict limit
          SizedBox(
            height: 180,
            width: double.infinity,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                validUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.fastfood, size: 50, color: Colors.grey),
              ),
            ),
          ),
          // -----------------------

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${food.price}',
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    // Add Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ADD',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
