// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_product_app/models/product.dart';
import 'package:flutter_product_app/screens/auth/login_screen.dart';
import 'package:flutter_product_app/screens/home/add_product_screen.dart';
import 'package:flutter_product_app/utils/shared_preferences_helper.dart';
import 'package:flutter_product_app/widgets/common_widgets.dart'; // Import common widgets

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _allProducts = []; // All products loaded from storage
  List<Product> _filteredProducts = []; // Products displayed after filtering/searching
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when the screen initializes.
    _loadProducts();
    // Listen for changes in the search input field.
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    // Dispose the search controller to prevent memory leaks.
    _searchController.dispose();
    super.dispose();
  }

  /// Loads products from SharedPreferences and updates the UI.
  Future<void> _loadProducts() async {
    showLoadingDialog(context, message: 'Loading products...');
    try {
      final products = await SharedPreferencesHelper.getProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products; // Initially, all products are filtered products
      });
      showToast('Products loaded!');
    } catch (e) {
      showToast('Failed to load products: ${e.toString()}', isError: true);
    } finally {
      Navigator.of(context).pop(); // Dismiss loading dialog
    }
  }

  /// Filters products based on the search query.
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Deletes a product from the list and updates storage.
  Future<void> _deleteProduct(String productId) async {
    // Show a confirmation dialog before deleting.
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this product?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Dismiss and return false
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Dismiss and return true
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      showLoadingDialog(context, message: 'Deleting product...');
      setState(() {
        _allProducts.removeWhere((product) => product.id == productId);
        _filterProducts(); // Re-filter to update the displayed list
      });
      try {
        await SharedPreferencesHelper.saveProducts(_allProducts);
        showToast('Product deleted successfully!');
      } catch (e) {
        showToast('Failed to delete product: ${e.toString()}', isError: true);
      } finally {
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }

  /// Handles user logout.
  Future<void> _logout() async {
    // Show a confirmation dialog before logging out.
    final bool confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmLogout) {
      showLoadingDialog(context, message: 'Logging out...');
      try {
        await SharedPreferencesHelper.clearAllData(); // Clear all user data
        await SharedPreferencesHelper.setLoggedIn(false); // Set login status to false
        showToast('Logged out successfully!');
        // Navigate back to the LoginScreen and remove all previous routes.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        showToast('Logout failed: ${e.toString()}', isError: true);
      } finally {
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                hintStyle: TextStyle(color: Colors.grey[700]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
      body: _filteredProducts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No Product Found',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tap the + button to add new products.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            product.imageUrl ?? 'https://placehold.co/80x80/E0E0E0/424242?text=No+Img',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E283F),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
                          tooltip: 'Delete Product',
                          onPressed: () => _deleteProduct(product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddProductScreen and wait for the result.
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          // If a product was added, reload the product list.
          if (result == true) {
            _loadProducts();
          }
        },
        backgroundColor: Colors.blue,
        tooltip: 'Add New Product',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
