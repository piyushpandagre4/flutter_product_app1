// lib/utils/shared_preferences_helper.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart'; // Import the Product model

class SharedPreferencesHelper {
  // Keys for storing data in SharedPreferences.
  static const String _loggedInKey = 'isLoggedIn';
  static const String _productsKey = 'products';

  /// Sets the login status of the user.
  ///
  /// [value] is true if the user is logged in, false otherwise.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  /// Checks if the user is currently logged in.
  ///
  /// Returns true if logged in, false otherwise (defaults to false if not set).
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  /// Saves a list of products to SharedPreferences.
  ///
  /// Converts each Product object to a JSON string before saving.
  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> productJsonList =
        products.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_productsKey, productJsonList);
  }

  /// Retrieves a list of products from SharedPreferences.
  ///
  /// Converts each JSON string back to a Product object.
  /// Returns an empty list if no products are found.
  static Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? productJsonList = prefs.getStringList(_productsKey);
    if (productJsonList == null) {
      return [];
    }
    // Map each JSON string back to a Product object.
    return productJsonList
        .map((jsonString) => Product.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  /// Clears all data stored in SharedPreferences.
  ///
  /// This is typically used for logout.
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
