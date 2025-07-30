class MotherUser {
  final int id;
  final String name;
  final String? phone;

  MotherUser({
    required this.id,
    required this.name,
    this.phone,
  });

  factory MotherUser.fromJson(Map<String, dynamic> json) {
    return MotherUser(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}

class Mother {
  final int id;
  final String kitchenName;
  final String bio;
  final String location;
  final String? profilePicture;
  final bool isVerified;
  final String rating;
  final MotherUser user;
  final String createdAt;
  final String updatedAt;

  Mother({
    required this.id,
    required this.kitchenName,
    required this.bio,
    required this.location,
    this.profilePicture,
    required this.isVerified,
    required this.rating,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mother.fromJson(Map<String, dynamic> json) {
    return Mother(
      id: json['id'],
      kitchenName: json['kitchen_name'],
      bio: json['bio'],
      location: json['location'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'],
      rating: json['rating'],
      user: MotherUser.fromJson(json['user']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kitchen_name': kitchenName,
      'bio': bio,
      'location': location,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
      'rating': rating,
      'user': user.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class MothersResponse {
  final List<Mother> data;
  final Map<String, dynamic> links;
  final Map<String, dynamic> meta;

  MothersResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory MothersResponse.fromJson(Map<String, dynamic> json) {
    return MothersResponse(
      data: (json['data'] as List)
          .map((mother) => Mother.fromJson(mother))
          .toList(),
      links: json['links'],
      meta: json['meta'],
    );
  }
}