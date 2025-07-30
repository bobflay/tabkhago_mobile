import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://emica.xpertbot.online/api';
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';

  // Test API connectivity
  Future<bool> testApiConnectivity() async {
    try {
      print('AuthService: Testing API connectivity...');
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('AuthService: API test response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404; // 404 is fine, means API is reachable
    } catch (e) {
      print('AuthService: API connectivity test failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('AuthService: Starting login process');
      print('AuthService: Email: $email');
      print('AuthService: URL: $baseUrl/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('AuthService: Response status code: ${response.statusCode}');
      print('AuthService: Response headers: ${response.headers}');
      print('AuthService: Response body: ${response.body}');
      
      if (response.body.isEmpty) {
        print('AuthService: Response body is empty!');
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }
      
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
        print('AuthService: Parsed data: $data');
      } catch (e) {
        print('AuthService: JSON parsing failed: $e');
        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }
      
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == true) {
        print('AuthService: Login successful, saving token and user data');
        
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, data['access_token']);
        await prefs.setString(userKey, jsonEncode(data['user']));
        
        print('AuthService: Token and user data saved successfully');
        
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
          'token': data['access_token'],
        };
      } else {
        print('AuthService: Login failed - Status code: ${response.statusCode}, Status: ${data['status']}');
        print('AuthService: Error message: ${data['message']}');
        print('AuthService: Expected status code 200 or 201 with status=true');
        
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('AuthService: Exception occurred: $e');
      
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);
      
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, data['access_token']);
        await prefs.setString(userKey, jsonEncode(data['user']));
        
        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['user']),
          'token': data['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}