// lib/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  final String? productId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String?,
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  OrderItem copyWith({int? quantity}) {
    final q = quantity ?? this.quantity;
    return OrderItem(
      productId: productId,
      name: name,
      price: price,
      quantity: q,
      subtotal: price * q,
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantPhone,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.items,
  });

  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantPhone;
  final DateTime? createdAt;
  final String status;
  final double total;
  final List<OrderItem> items;

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawItems = (data['items'] as List<dynamic>?) ?? [];

    return OrderModel(
      id: doc.id,
      restaurantName: (data['restaurantName'] as String?) ?? 'FOODZONE',
      restaurantAddress: (data['restaurantAddress'] as String?) ?? '',
      restaurantPhone: (data['restaurantPhone'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      status: (data['status'] as String?) ?? 'completed',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      items: rawItems
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'restaurantPhone': restaurantPhone,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'status': status,
      'total': total,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}