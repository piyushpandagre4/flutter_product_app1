// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_product_app/api/auth_api.dart';
import 'package:flutter_product_app/screens/home/home_screen.dart';
import 'package:flutter_product_app/utils/shared_preferences_helper.dart';
import 'package:flutter_product_app/widgets/common_widgets.dart'; // Import common widgets

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for email and password input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Global key for the form, used for validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // State variable to toggle password visibility.
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill email and password for quick testing as per the task.
    _emailController.text = 'eve.holt@reqres.in';
    _passwordController.text = 'pistol';
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login process when the login button is pressed.
  Future<void> _handleLogin() async {
    // Validate the form fields.
    if (_formKey.currentState!.validate()) {
      // Show loading dialog.
      showLoadingDialog(context);

      try {
        // Call the login API.
        final token = await AuthApi.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Dismiss loading dialog.
        Navigator.of(context).pop();

        if (token != null) {
          // If login is successful, save login status and navigate to home screen.
          await SharedPreferencesHelper.setLoggedIn(true);
          showToast('Login successful!');
          // Replace current screen with HomeScreen to prevent going back to login.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // This case should ideally be covered by the AuthApi throwing an exception.
          showToast('Login failed. Please try again.', isError: true);
        }
      } catch (e) {
        // Dismiss loading dialog on error.
        Navigator.of(context).pop();
        // Show error message using toast.
        showToast(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image above the login form.
                Image.network(
                  'https://placehold.co/200x200/F0F8FF/000000?text=Illustration', // Placeholder image
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/placeholder_illustration.png', // Fallback for local asset
                      height: 200,
                      fit: BoxFit.contain,
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E283F),
                  ),
                ),
                const SizedBox(height: 30),
                // Email input field.
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email ID',
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password input field.
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 4) { // As per reqres.in, 'pistol' is 6 chars, but a minimum of 4 is a common practice.
                      return 'Password must be at least 4 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showToast('Forgot Password functionality is not implemented.', isError: false);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Login button.
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                      ),
                      shadowColor: Colors.blue.withOpacity(0.5), // Shadow color
                      elevation: 8, // Elevation
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // This section is explicitly stated NOT to be built with Google login,
                // but included for visual resemblance from the screenshot.
                // It will just show a toast if pressed.
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      showToast('Login with Google is not implemented as per task.', isError: false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700], side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.google.com/favicon.ico', // Simple Google icon placeholder
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue); // Fallback icon
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Login with Google',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to Logistics?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        showToast('Register functionality is not implemented.', isError: false);
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
