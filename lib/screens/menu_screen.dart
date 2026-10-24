// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';
import '../Provider/menu_provider.dart';
import '../Provider/product_provider.dart';
import '../category/category_chips.dart';
import '../models/product_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'menu_product_card.dart';
import 'product_detail_screen.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAdd() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => const AddProductScreen()),
    );
  }

  /// Arrow button → Product Detail screen (image, description, quantity, add to cart)
  void _openDetail(Product product) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  /// Optional: keep edit available if you need it later
  void _openEdit(Product product) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => EditProductScreen(product: product),
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final id = product.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete product?'),
        content: Text(
          '“${product.name}” will be permanently removed from the menu.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.black87,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(productListProvider.notifier).deleteProduct(id);
    } catch (error) {
      debugPrint('Delete failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the product. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(menuProductsProvider);
    final query = ref.watch(menuSearchProvider);
    final category = ref.watch(menuCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 84.h,
        titleSpacing: 20.w,
        title: const _NourishTitle(),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: IconButton(
              tooltip: 'Add item',
              onPressed: _openAdd,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                fixedSize: Size.square(44.w),
              ),
              icon: Icon(
                Icons.add_box_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
            child: TextField(
              controller: _searchController,
              onChanged: ref.read(menuSearchProvider.notifier).setQuery,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search for products, cuisines...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: query.isEmpty
                    ? const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textSecondary,
                )
                    : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(menuSearchProvider.notifier).clear();
                  },
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          // Category chips
          CategoryChips(
            selected: category,
            onSelected: ref.read(menuCategoryProvider.notifier).select,
          ),
          SizedBox(height: 12.h),

          // Product list
          Expanded(
            child: products.isEmpty
                ? _MessageState(
              icon: _isFiltering(query, category)
                  ? Icons.search_off_rounded
                  : Icons.restaurant_menu_rounded,
              title: _isFiltering(query, category)
                  ? 'No products found'
                  : 'No products yet',
              subtitle: _isFiltering(query, category)
                  ? 'Try a different search or category.'
                  : 'Tap the add icon to create your first item.',
            )
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final id = product.id ?? '';
                return MenuProductCard(
                  key: ValueKey<String>(id),
                  product: product,
                  index: index,
                  onDelete: () => _confirmDelete(product),
                  onOpen: () => _openDetail(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isFiltering(String query, String category) =>
      query.trim().isNotEmpty || category != 'All';
}

/// "NOURISH" wordmark + tagline
class _NourishTitle extends StatelessWidget {
  const _NourishTitle();

  static const String _tagline = 'GOOD FOOD  ·  BRIGHTER DAYS';

  Widget _letters(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 30.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
        height: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _letters('N'),
            SizedBox(width: 3.w),
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2.5),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
            ),
            _letters('URISH'),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          _tagline,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 8.sp,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

/// Empty / no-results state
class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56.sp, color: AppColors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}