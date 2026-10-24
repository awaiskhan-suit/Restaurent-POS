// lib/Provider/orders_list_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';

final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(OrderModel.fromDoc).toList());
});

class OrdersActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> deleteOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateOrder(OrderModel order) async {
    state = const AsyncValue.loading();
    try {
      // Recalculate total from items
      final total = order.items.fold<double>(0, (sum, e) => sum + e.subtotal);
      final updated = {
        'status': order.status,
        'total': total,
        'items': order.items.map((e) => e.toMap()).toList(),
      };
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update(updated);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final ordersActionsProvider =
NotifierProvider<OrdersActionsNotifier, AsyncValue<void>>(
  OrdersActionsNotifier.new,
);