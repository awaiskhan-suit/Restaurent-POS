// lib/Provider/order_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_provider.dart';

class OrderNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> placeOrder(List<CartItem> items, double total) async {
    if (items.isEmpty) return false;

    state = const AsyncValue.loading();

    try {
      final orderData = {
        'restaurantName': 'FOODZONE',
        'restaurantAddress':
        'Shop #12, Main Boulevard, Gulberg III, Lahore, Pakistan',
        'restaurantPhone': '+92 345 6536877',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'completed',
        'total': total,
        'items': items
            .map((e) => {
          'productId': e.product.id,
          'name': e.product.name,
          'price': e.product.price,
          'quantity': e.quantity,
          'subtotal': e.total,
        })
            .toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final orderProvider =
NotifierProvider<OrderNotifier, AsyncValue<void>>(OrderNotifier.new);