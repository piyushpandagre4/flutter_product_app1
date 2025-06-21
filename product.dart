// lib/models/product.dart

class Product {
  String id; // Unique ID for each product
  String name;
  double price;
  String? imageUrl; // Optional image URL for the product

  Product({required this.id, required this.name, required this.price, this.imageUrl});

  /// Converts a Product object to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a Product object from a JSON map.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as double,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
