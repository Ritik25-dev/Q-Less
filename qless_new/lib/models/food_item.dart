class FoodItem {
  final String id;
  final String foodId; // It's fine to have this
  final String name; // <-- MAKE SURE YOU STILL HAVE THIS!
  final double price;
  final String imageUrl;
  bool isAvailable;
  final String category;

  FoodItem({
    required this.id,
    required this.foodId,
    required this.name, // <-- AND THIS
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.category,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['_id'] ?? '',
      foodId: json['item'] ?? '',
      name: json['name'] ?? 'Unknown Item', // <-- AND THIS
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['pic'] != null && json['pic']['url'] != null
          ? json['pic']['url']
          : 'https://via.placeholder.com/150',
      isAvailable: json['isAvailable'] ?? true,
      category: json['category'] ?? 'General',
    );
  }
}
