// ignore_for_file: unused_import

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      'https://senior-project-production-37a0.up.railway.app/api'; // Replace with your Laravel API URL

  static Future<Map<String, dynamic>> signup(String email, String name,
      String password, String password_confirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: {
        'email': email,
        'name': name,
        'password': password,
        'password_confirmation': password_confirmation,
      },
    );
   if (response.statusCode == 200) {
      // Signup successful, parse the response body
      final responseData = json.decode(response.body);
      final user = responseData['user'];
      final token = responseData['token'];

      return {
        'success': true,
        'user': user,
        'token': token,
      };
    } else {
      // Signup failed, parse the error message
      final responseData = json.decode(response.body);
      final errorMessage = responseData['message'];

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );
    print(response.body);
    return response;
  }

  static Future<http.Response> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
