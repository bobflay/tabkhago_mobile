import 'user.dart';
import 'dish.dart';

class Order {
  final int id;
  final User user;
  final Dish dish;
  final int quantity;
  final String priceTotal;
  final String status;
  final String paymentMethod;
  final String deliveryAddress;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Order({
    required this.id,
    required this.user,
    required this.dish,
    required this.quantity,
    required this.priceTotal,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      user: User.fromJson(json['user']),
      dish: Dish.fromJson(json['dish']),
      quantity: json['quantity'],
      priceTotal: json['price_total'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      deliveryAddress: json['delivery_address'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'dish': dish.toJson(),
      'quantity': quantity,
      'price_total': priceTotal,
      'status': status,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  double get priceTotalAsDouble => double.tryParse(priceTotal) ?? 0.0;
}

class OrderRequest {
  final int dishId;
  final int quantity;
  final String paymentMethod;
  final String deliveryAddress;
  final String? notes;

  OrderRequest({
    required this.dishId,
    required this.quantity,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'dish_id': dishId,
      'quantity': quantity,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
      'notes': notes,
    };
  }
}