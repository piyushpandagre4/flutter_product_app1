// lib/screens/home/add_product_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_product_app/models/product.dart';
import 'package:flutter_product_app/utils/shared_preferences_helper.dart';
import 'package:flutter_product_app/widgets/common_widgets.dart'; // Import common widgets
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers for text input fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  // Global key for form validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Uuid instance for generating unique IDs.
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Handles the process of adding a new product.
  Future<void> _addProduct() async {
    // Validate the form fields.
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context, message: 'Adding product...');

      try {
        final String productName = _nameController.text.trim();
        final double productPrice = double.parse(_priceController.text.trim());
        final String? imageUrl = _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim();

        // Retrieve existing products to check for duplication.
        List<Product> existingProducts = await SharedPreferencesHelper.getProducts();

        // Check for product duplication by name (case-insensitive).
        if (existingProducts.any((p) => p.name.toLowerCase() == productName.toLowerCase())) {
          // Dismiss loading dialog.
          Navigator.of(context).pop();
          showToast('Product with this name already exists.', isError: true);
          return; // Stop execution if duplicate found.
        }

        // Generate a unique ID for the new product.
        final String newProductId = _uuid.v4();

        // Create a new Product object.
        final newProduct = Product(
          id: newProductId,
          name: productName,
          price: productPrice,
          imageUrl: imageUrl,
        );

        // Add the new product to the existing list.
        existingProducts.add(newProduct);

        // Save the updated list of products.
        await SharedPreferencesHelper.saveProducts(existingProducts);

        // Dismiss loading dialog.
        Navigator.of(context).pop();
        showToast('Product added successfully!');

        // Navigate back to the home screen, indicating a successful addition.
        Navigator.of(context).pop(true);
      } catch (e) {
        // Dismiss loading dialog on error.
        Navigator.of(context).pop();
        showToast('Failed to add product: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E283F),
                ),
              ),
              const SizedBox(height: 20),
              // Product Name Input
              CustomTextField(
                controller: _nameController,
                hintText: 'Product Name',
                prefixIcon: const Icon(Icons.label_outline, color: Colors.grey),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Price Input
              CustomTextField(
                controller: _priceController,
                hintText: 'Price',
                prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number for price';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Image URL Input (Optional)
              CustomTextField(
                controller: _imageUrlController,
                hintText: 'Image URL (Optional)',
                prefixIcon: const Icon(Icons.image_outlined, color: Colors.grey),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Simple URL validation
                    if (!Uri.tryParse(value)?.hasAbsolutePath ?? true) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // Add Product Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    shadowColor: Colors.blue.withOpacity(0.5),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
