import 'package:flutter/material.dart';

// --- THE CART ITEM MODEL ---
class CartItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl; // Added to show images in the cart!
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });
}

// --- THE CART PROVIDER ---
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  // Calculates the grand total
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Gets the specific quantity for a food item
  int getQuantity(String foodId) {
    if (_items.containsKey(foodId)) {
      return _items[foodId]!.quantity;
    }
    return 0;
  }

  // Adds an item to the cart (or increases quantity)
  void addItem(dynamic food) {
    if (_items.containsKey(food.id)) {
      _items.update(
        food.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl, // Preserve the image
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        food.id,
        () => CartItem(
          id: food.id,
          name: food.name,
          price: food.price,
          imageUrl: food.imageUrl, // Save the image when first added
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Decreases quantity (or removes if it reaches 0)
  void removeItem(String foodId) {
    if (!_items.containsKey(foodId)) return;

    if (_items[foodId]!.quantity > 1) {
      _items.update(
        foodId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(foodId);
    }
    notifyListeners();
  }

  // Deletes an item completely regardless of quantity
  void deleteItem(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  // Clears the entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addCartItem(CartItem item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += item.quantity;
    } else {
      _items[item.id] = item;
    }
    notifyListeners();
  }
}
