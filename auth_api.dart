// lib/api/auth_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // Base URL for the authentication API.
  static const String _baseUrl = 'https://reqres.in/api';

  /// Authenticates a user with the provided email and password.
  ///
  /// Returns a token string upon successful login.
  /// Throws an Exception if login fails or a network error occurs.
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'), // Construct the full login API URL.
        headers: {'Content-Type': 'application/json'}, // Set content type to JSON.
        body: jsonEncode({ // Encode the email and password into a JSON string.
          'email': email,
          'password': password,
        }),
      );

      // Check if the HTTP response status code is 200 (OK).
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Parse the JSON response body.
        return data['token']; // Extract and return the 'token' from the response.
      } else {
        // If login fails (status code not 200), parse the error message.
        final errorData = jsonDecode(response.body);
        // Throw an exception with a specific error message or a generic one.
        throw Exception(errorData['error'] ?? 'Login failed. Please check your credentials.');
      }
    } catch (e) {
      // Catch any exceptions that occur during the HTTP request (e.g., network issues).
      print('Login API error: $e'); // Log the error for debugging.
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }
}
