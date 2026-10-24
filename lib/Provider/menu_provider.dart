// lib/Provider/menu_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import 'product_provider.dart'; // productListProvider (StateNotifier<List<Product>>)

/// Search text typed in the menu search bar.
class MenuSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

final menuSearchProvider =
NotifierProvider<MenuSearchNotifier, String>(MenuSearchNotifier.new);

/// Selected category chip. 'All' means no category filter.
class MenuCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void select(String category) => state = category;
}

final menuCategoryProvider =
NotifierProvider<MenuCategoryNotifier, String>(MenuCategoryNotifier.new);

/// IDs of favourited products (in memory only).
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String productId) {
    state = state.contains(productId)
        ? (Set<String>.of(state)..remove(productId))
        : {...state, productId};
  }
}

final favoritesProvider =
NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Selected bottom-navigation tab.
class MenuNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final menuNavIndexProvider =
NotifierProvider<MenuNavIndexNotifier, int>(MenuNavIndexNotifier.new);

/// Products shown on the menu: your product list filtered by category + search.
final menuProductsProvider = Provider<List<Product>>((ref) {
  final query = ref.watch(menuSearchProvider).trim().toLowerCase();
  final category = ref.watch(menuCategoryProvider);
  final products = ref.watch(productListProvider); // List<Product>

  return products.where((p) {
    final matchesCategory = category == 'All' || p.category == category;
    final matchesQuery = query.isEmpty || p.name.toLowerCase().contains(query);
    return matchesCategory && matchesQuery;
  }).toList();
});

