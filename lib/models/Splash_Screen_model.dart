import 'package:flutter/foundation.dart';

// =============================================================================
// AUTH
// =============================================================================
enum AuthStatus { unauthenticated, guest, authenticated }

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.isLoading = false,
    this.userName,
    this.error,
  });

  final AuthStatus status;
  final bool isLoading;
  final String? userName;
  final String? error;

  bool get isLoggedIn => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? userName,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// =============================================================================
// FOOD
// =============================================================================
@immutable
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.imageAsset,
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final String imageAsset;
  final bool isPopular;

  /// 1200 -> "1.2k reviews", 860 -> "860 reviews"
  String get reviewsLabel => reviewCount >= 1000
      ? '${(reviewCount / 1000).toStringAsFixed(1)}k reviews'
      : '$reviewCount reviews';

  /// 12 -> "$12.00"
  String get priceLabel => '\$${price.toStringAsFixed(2)}';
}

// =============================================================================
// CART
// =============================================================================
@immutable
class CartItem {
  const CartItem({required this.food, required this.quantity});

  final FoodItem food;
  final int quantity;

  double get total => food.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(food: food, quantity: quantity ?? this.quantity);
}
