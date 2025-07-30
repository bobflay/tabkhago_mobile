import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'auth_service.dart';

class OrderService {
  static const String baseUrl = 'https://emica.xpertbot.online/api';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> placeOrder(OrderRequest orderRequest) async {
    try {
      print('OrderService: Placing order...');
      print('OrderService: Order data: ${orderRequest.toJson()}');
      
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderRequest.toJson()),
      );

      print('OrderService: Response status code: ${response.statusCode}');
      print('OrderService: Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('OrderService: JSON parsing failed: $e');
        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('OrderService: Order placed successfully');
        print('OrderService: Attempting to parse order data...');
        
        try {
          final order = Order.fromJson(data['data']);
          print('OrderService: Order parsed successfully');
          
          return {
            'success': true,
            'message': data['message'] ?? 'Order placed successfully!',
            'order': order,
          };
        } catch (e) {
          print('OrderService: Error parsing order: $e');
          print('OrderService: Order data that failed to parse: ${data['data']}');
          
          // Return success but without order object for now
          return {
            'success': true,
            'message': data['message'] ?? 'Order placed successfully!',
          };
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        print('OrderService: Order failed - Status code: ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to place order',
        };
      }
    } catch (e) {
      print('OrderService: Exception occurred: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<List<Order>?> getUserOrders() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ordersData = data['data'] ?? [];
        return ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      print('OrderService: Cancelling order $orderId...');
      
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('OrderService: Cancel response status code: ${response.statusCode}');
      print('OrderService: Cancel response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('OrderService: JSON parsing failed: $e');
        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      if (response.statusCode == 200) {
        print('OrderService: Order cancelled successfully');
        
        try {
          final cancelledOrder = Order.fromJson(data['data']);
          return {
            'success': true,
            'message': data['message'] ?? 'Order cancelled successfully!',
            'order': cancelledOrder,
          };
        } catch (e) {
          print('OrderService: Error parsing cancelled order: $e');
          return {
            'success': true,
            'message': data['message'] ?? 'Order cancelled successfully!',
          };
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': data['message'] ?? 'Cannot cancel this order',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Order not found',
        };
      } else {
        print('OrderService: Cancel failed - Status code: ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      print('OrderService: Exception occurred while cancelling: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}