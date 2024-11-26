// Enums for Post properties

enum InstrumentType {
  Guitar,
  Piano,
  Violin,
  Drums
}

enum Availability {
  sold,
  rented,
  available
}

enum PostStatus {
  forSale,
  forRental
}

class Post {
  final String id;
  final String userId;
  final InstrumentType instrumentType;
  final String brand;
  final String title;
  final double price;
  final String? description;
  final String phoneNumber;
  final String? image;
  final Availability availability;
  final PostStatus status;
  final String location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  var error;

  Post({
    required this.id,
    required this.userId,
    required this.instrumentType,
    required this.brand,
    required this.title,
    required this.price,
    this.description,
    required this.phoneNumber,
    this.image,
    required this.availability,
    required this.status,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  // Helper method to convert string to InstrumentType
  static InstrumentType _stringToInstrumentType(String type) {
    return InstrumentType.values.firstWhere(
          (e) => e.toString().split('.').last == type,
      orElse: () => throw Exception('Invalid instrument type: $type'),
    );
  }

  // Helper method to convert string to Availability
  static Availability _stringToAvailability(String availability) {
    return Availability.values.firstWhere(
          (e) => e.toString().split('.').last == availability,
      orElse: () => throw Exception('Invalid availability: $availability'),
    );
  }

  // Helper method to convert string to PostStatus
  static PostStatus _stringToPostStatus(String status) {
    return PostStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (status == 'for sale' ? 'forSale' : 'forRental'),
      orElse: () => throw Exception('Invalid status: $status'),
    );
  }

  // Create Post from JSON data
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      instrumentType: _stringToInstrumentType(json['instrument_type']),
      brand: json['brand'],
      title: json['title'],
      price: json['price'].toDouble(),
      description: json['description'],
      phoneNumber: json['phone_number'],
      image: json['image'],
      availability: _stringToAvailability(json['availability']),
      status: _stringToPostStatus(json['status']),
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'instrument_type': instrumentType.toString().split('.').last,
      'brand': brand,
      'title': title,
      'price': price,
      'description': description,
      'phone_number': phoneNumber,
      'image': image,
      'availability': availability.toString().split('.').last,
      'status': status == PostStatus.forSale ? 'for sale' : 'for rental',
      'location': location,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy of Post with modified fields
  Post copyWith({
    String? id,
    String? userId,
    InstrumentType? instrumentType,
    String? brand,
    String? title,
    double? price,
    String? description,
    String? phoneNumber,
    String? image,
    Availability? availability,
    PostStatus? status,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      instrumentType: instrumentType ?? this.instrumentType,
      brand: brand ?? this.brand,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image ?? this.image,
      availability: availability ?? this.availability,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// DTO for creating a new post
class CreatePostDto {
  final String userId;
  final InstrumentType instrumentType;
  final String brand;
  final String title;
  final double price;
  final String? description;
  final String phoneNumber;
  final String image;
  final Availability availability;
  final PostStatus status;
  final String location;

  CreatePostDto({
    required this.userId,
    required this.instrumentType,
    required this.brand,
    required this.title,
    required this.price,
    this.description,
    required this.phoneNumber,
    required this.image,
    required this.availability,
    required this.status,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'instrument_type': instrumentType.toString().split('.').last,
      'brand': brand,
      'title': title,
      'price': price,
      'description': description,
      'phone_number': phoneNumber,
      'image': image,
      'availability': availability.toString().split('.').last,
      'status': status == PostStatus.forSale ? 'for sale' : 'for rental',
      'location': location,
    };
  }
}