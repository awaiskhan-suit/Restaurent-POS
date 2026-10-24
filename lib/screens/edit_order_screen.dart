// lib/screens/edit_order_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';
import '../Provider/orders_list_provider.dart';
import '../Provider/product_provider.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class EditOrderScreen extends ConsumerStatefulWidget {
  const EditOrderScreen({super.key, required this.order});

  final OrderModel order;

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  late String _status;
  late List<OrderItem> _items;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _items = List<OrderItem>.from(widget.order.items);
  }

  double get _total => _items.fold(0.0, (s, e) => s + e.subtotal);

  String _formatPrice(double v) {
    final d = v % 1 == 0 ? 0 : 2;
    return 'Rs ${v.toStringAsFixed(d)}';
  }

  Future<void> _confirmRemoveItem(int index) async {
    final item = _items[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove item?'),
        content: Text(
          '“${item.name}” will be removed from this order.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.black87,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _items.removeAt(index));
    }
  }

  Future<void> _openAddProduct() async {
    final products = ref.read(productListProvider);
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No products available to add.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final Product? selected = await showModalBottomSheet<Product>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Add product',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.white12,
                    ),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          p.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _formatPrice(p.price),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.sp,
                          ),
                        ),
                        trailing: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                        onTap: () => Navigator.of(ctx).pop(p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      final existingIndex = _items.indexWhere(
            (e) => e.productId != null && e.productId == selected.id,
      );

      if (existingIndex != -1) {
        // Already in order → increase quantity
        final existing = _items[existingIndex];
        _items[existingIndex] =
            existing.copyWith(quantity: existing.quantity + 1);
      } else {
        _items.add(
          OrderItem(
            productId: selected.id,
            name: selected.name,
            price: selected.price,
            quantity: 1,
            subtotal: selected.price,
          ),
        );
      }
    });
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order must have at least one item.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updated = OrderModel(
      id: widget.order.id,
      restaurantName: widget.order.restaurantName,
      restaurantAddress: widget.order.restaurantAddress,
      restaurantPhone: widget.order.restaurantPhone,
      createdAt: widget.order.createdAt,
      status: _status,
      total: _total,
      items: _items,
    );

    final ok =
    await ref.read(ordersActionsProvider.notifier).updateOrder(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Order updated' : 'Update failed'),
        backgroundColor: ok ? Colors.green.shade700 : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(ordersActionsProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Edit Order',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: _openAddProduct,
            icon: Icon(
              Icons.add_box_rounded,
              color: AppColors.primary,
              size: 26.sp,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'Status',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: ['completed', 'pending', 'cancelled'].map((s) {
              final selected = _status == s;
              return ChoiceChip(
                label: Text(s.toUpperCase()),
                selected: selected,
                onSelected: (_) => setState(() => _status = s),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Text(
                'Items',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openAddProduct,
                icon: Icon(Icons.add, size: 18.sp, color: AppColors.primary),
                label: Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (_items.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'No items. Tap Add to include products.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            )
          else
            ...List.generate(_items.length, (i) {
              final item = _items[i];
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _formatPrice(item.subtotal),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: item.quantity > 1
                          ? () => setState(() {
                        _items[i] = item.copyWith(
                          quantity: item.quantity - 1,
                        );
                      })
                          : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _items[i] =
                            item.copyWith(quantity: item.quantity + 1);
                      }),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      onPressed: () => _confirmRemoveItem(i),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              );
            }),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatPrice(_total),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              onPressed: saving ? null : _save,
              child: saving
                  ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textOnPrimary,
                ),
              )
                  : Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}