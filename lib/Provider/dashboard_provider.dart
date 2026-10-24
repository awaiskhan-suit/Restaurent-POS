// lib/Provider/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import 'orders_list_provider.dart';
import 'product_provider.dart';

class SoldItemStat {
  const SoldItemStat({
    required this.name,
    required this.quantity,
    required this.revenue,
    this.productId,
  });

  final String name;
  final int quantity;
  final double revenue;
  final String? productId;
}

class DashboardStats {
  const DashboardStats({
    required this.totalSell,
    required this.todaySell,
    required this.totalOrders,
    required this.todayOrders,
    required this.todayItems,
    required this.topSellingItems,
  });

  final double totalSell;
  final double todaySell;
  final int totalOrders;
  final int todayOrders;
  final List<SoldItemStat> todayItems;
  final List<SoldItemStat> topSellingItems;

  static const empty = DashboardStats(
    totalSell: 0,
    todaySell: 0,
    totalOrders: 0,
    todayOrders: 0,
    todayItems: [],
    topSellingItems: [],
  );
}

bool _isSameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Map<String, SoldItemStat> _aggregateItems(Iterable<OrderItem> items) {
  final map = <String, SoldItemStat>{};

  for (final item in items) {
    final key = item.name.trim().isEmpty ? 'Unknown' : item.name.trim();
    final existing = map[key];
    if (existing == null) {
      map[key] = SoldItemStat(
        name: key,
        quantity: item.quantity,
        revenue: item.subtotal,
        productId: item.productId,
      );
    } else {
      map[key] = SoldItemStat(
        name: key,
        quantity: existing.quantity + item.quantity,
        revenue: existing.revenue + item.subtotal,
        productId: existing.productId ?? item.productId,
      );
    }
  }

  return map;
}

List<SoldItemStat> _sortedByQuantity(Map<String, SoldItemStat> map) {
  final list = map.values.toList()
    ..sort((a, b) => b.quantity.compareTo(a.quantity));
  return list;
}

/// Find product for image (by id, then by name).
Product? findProductForStat(List<Product> products, SoldItemStat stat) {
  if (stat.productId != null && stat.productId!.isNotEmpty) {
    try {
      return products.firstWhere((p) => p.id == stat.productId);
    } catch (_) {}
  }
  final name = stat.name.toLowerCase();
  try {
    return products.firstWhere((p) => p.name.toLowerCase() == name);
  } catch (_) {
    return null;
  }
}

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);

  return ordersAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (orders) {
      final now = DateTime.now();

      double totalSell = 0;
      double todaySell = 0;
      int todayOrders = 0;

      final todayOrderItems = <OrderItem>[];
      final allOrderItems = <OrderItem>[];

      for (final order in orders) {
        totalSell += order.total;
        allOrderItems.addAll(order.items);

        if (_isSameDay(order.createdAt, now)) {
          todaySell += order.total;
          todayOrders++;
          todayOrderItems.addAll(order.items);
        }
      }

      final todayItems = _sortedByQuantity(_aggregateItems(todayOrderItems));
      final topSelling = _sortedByQuantity(_aggregateItems(allOrderItems));

      return AsyncValue.data(
        DashboardStats(
          totalSell: totalSell,
          todaySell: todaySell,
          totalOrders: orders.length,
          todayOrders: todayOrders,
          todayItems: todayItems,
          topSellingItems: topSelling.take(10).toList(),
        ),
      );
    },
  );
});