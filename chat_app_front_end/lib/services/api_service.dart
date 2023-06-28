import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      'https://senior-project-production-37a0.up.railway.app/api'; // Replace with your Laravel API URL

  static Future<http.Response> signup(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {
        'email': email,
        'password': password,
      },
    );

    return response;
  }

  static Future<http.Response> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

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
