// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_product_app/screens/auth/login_screen.dart';
import 'package:flutter_product_app/screens/home/home_screen.dart';
import 'package:flutter_product_app/utils/shared_preferences_helper.dart';

void main() {
  // Ensure that Flutter binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State variables to manage login status and loading state.
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Check the user's login status when the app starts.
    _checkLoginStatus();
  }

  /// Checks if the user is already logged in using SharedPreferences.
  Future<void> _checkLoginStatus() async {
    // Retrieve login status from SharedPreferences.
    _isLoggedIn = await SharedPreferencesHelper.isLoggedIn();
    setState(() {
      // Update the loading state once the login status is determined.
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking the login status.
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Once loading is complete, determine the initial screen based on login status.
    return MaterialApp(
      title: 'Product App',
      // Disable the debug banner in release mode.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the primary color swatch for the application.
        primarySwatch: Colors.blue,
        // Apply rounded corners to elevated buttons for a modern look.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          ),
        ),
        // Apply rounded corners to text form fields.
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
      // Set the initial screen based on whether the user is logged in.
      home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
      // Define named routes for easy navigation.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
