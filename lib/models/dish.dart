import 'mother.dart';

class Dish {
  final int id;
  final String name;
  final String description;
  final String? photo;
  final String price;
  final int availableQuantity;
  final bool isActive;
  final Mother mother;
  final String createdAt;
  final String updatedAt;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    this.photo,
    required this.price,
    required this.availableQuantity,
    required this.isActive,
    required this.mother,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      price: json['price'],
      availableQuantity: json['available_quantity'],
      isActive: json['is_active'],
      mother: Mother.fromJson(json['mother']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo': photo,
      'price': price,
      'available_quantity': availableQuantity,
      'is_active': isActive,
      'mother': mother.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;
  double get ratingAsDouble => double.tryParse(mother.rating) ?? 0.0;
}