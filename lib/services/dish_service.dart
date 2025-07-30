import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dishes_response.dart';
import 'auth_service.dart';

class DishService {
  static const String baseUrl = 'https://emica.xpertbot.online/api';
  final AuthService _authService = AuthService();

  Future<DishesResponse?> getDishes({int page = 1}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dishes?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DishesResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load dishes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<DishesResponse?> searchDishes(String query, {int page = 1}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dishes?search=$query&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DishesResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to search dishes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}