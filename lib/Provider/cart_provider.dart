// lib/Provider/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  double get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product, {int quantity = 1}) {
    final index = state.indexWhere((e) => e.product.id == product.id);

    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: quantity)];
    } else {
      final existing = state[index];
      final updated = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) updated else state[i],
      ];
    }
  }

  void remove(String productId) {
    state = state.where((e) => e.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void clear() => state = [];
}

final cartProvider =
NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, e) => sum + e.quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, e) => sum + e.total);
});