
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/product_model.dart';

final productListProvider =
StateNotifierProvider<ProductNotifier, List<Product>>(
(ref) => ProductNotifier(),
);

class ProductNotifier extends StateNotifier<List<Product>> {
ProductNotifier() : super([]) {
_listenToProducts();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
_subscription;

// Listen to products from Firestore in real time.
void _listenToProducts() {
_subscription = _firestore
    .collection('products')
    .orderBy('created_at', descending: true)
    .snapshots()
    .listen(
(snapshot) {
state = snapshot.docs.map((doc) {
return Product.fromMap(
doc.data(),
doc.id,
);
}).toList();
},
onError: (Object error, StackTrace stackTrace) {
print('Error loading products: $error');
},
);
}

// Add a product.
// The imagePath should already point to a locally saved image.
Future<void> addProduct(Product product) async {
try {
final productData = product.toMap();

// Keep the locally saved image path.
productData['imagePath'] = product.imagePath;
productData['imageSource'] = product.imageSource.name;

await _firestore.collection('products').add(productData);
} catch (error) {
throw Exception('Failed to add product: $error');
}
}

// Update an existing product.
Future<void> updateProduct(
String productId,
Product product,
) async {
try {
if (productId.trim().isEmpty) {
throw ArgumentError('Product ID cannot be empty.');
}

final productData = product.toUpdateMap();

// Store the current image path and source.
productData['imagePath'] = product.imagePath;
productData['imageSource'] = product.imageSource.name;

await _firestore
    .collection('products')
    .doc(productId)
    .update(productData);
} catch (error) {
throw Exception('Failed to update product: $error');
}
}

// Delete a product.
Future<void> deleteProduct(String productId) async {
try {
if (productId.trim().isEmpty) {
throw ArgumentError('Product ID cannot be empty.');
}

await _firestore
    .collection('products')
    .doc(productId)
    .delete();
} catch (error) {
throw Exception('Failed to delete product: $error');
}
}

@override
void dispose() {
_subscription?.cancel();
super.dispose();
}
}
