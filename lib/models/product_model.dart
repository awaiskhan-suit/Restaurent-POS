import 'package:cloud_firestore/cloud_firestore.dart';

enum ImageSourceType { asset, file, network }

class Product {
  final String? id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imagePath; // local path OR Firebase Storage download URL
  final ImageSourceType imageSource;
  final DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.imageSource,
    this.createdAt,
  });

  // Used when creating a new product
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imagePath': imagePath,
      'imageSource': imageSource.name, // 'file' | 'network' | 'asset'
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  // Used when updating an existing product (does not overwrite created_at)
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imagePath': imagePath,
      'imageSource': imageSource.name,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      imageSource: ImageSourceType.values.firstWhere(
            (e) => e.name == map['imageSource'],
        orElse: () => ImageSourceType.network,
      ),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    String? imagePath,
    ImageSourceType? imageSource,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageSource: imageSource ?? this.imageSource,
      createdAt: createdAt,
    );
  }
}

