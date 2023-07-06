import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:8000/api'; // Replace with your API base URL

  static Future<Map<String, dynamic>> signup(String email, String password,
      String name, String passwordConfirmation) async {
    final url = Uri.parse('$baseUrl/signup');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'email': email,
      'password': password,
      'name': name,
      'password_confirmation': passwordConfirmation,
    };

    http.Response response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'email': email,
      'password': password,
    };

    http.Response response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    return jsonDecode(response.body);
  }
}
