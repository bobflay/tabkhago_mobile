import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mother.dart';

class MotherService {
  static const String baseUrl = 'https://emica.xpertbot.online/api';

  Future<MothersResponse?> getMothers({int page = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/mothers?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MothersResponse.fromJson(data);
      } else {
        throw Exception('Failed to load mothers. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Mother?> getMother(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/mothers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Mother.fromJson(data['data']);
      } else {
        throw Exception('Failed to load mother details. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}