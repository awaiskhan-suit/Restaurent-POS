// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';
import '../Provider/dashboard_provider.dart';
import '../Provider/product_image_provider.dart';
import '../Provider/product_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_image.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatPrice(double value) {
    final decimals = value % 1 == 0 ? 0 : 2;
    return 'Rs ${value.toStringAsFixed(decimals)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final products = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 84.h,
        titleSpacing: 20.w,
        title: const _NourishTitle(),
        automaticallyImplyLeading: false,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Could not load dashboard.\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        data: (stats) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),

                // Stat cards – 2x2
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Sell',
                        value: _formatPrice(stats.totalSell),
                        icon: Icons.payments_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _StatCard(
                        title: 'Today Sell',
                        value: _formatPrice(stats.todaySell),
                        icon: Icons.today_outlined,
                        color: Colors.greenAccent.shade400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Orders',
                        value: '${stats.totalOrders}',
                        icon: Icons.receipt_long_outlined,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _StatCard(
                        title: 'Today Orders',
                        value: '${stats.todayOrders}',
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Items sold today
                Text(
                  'Items sold today',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                if (stats.todayItems.isEmpty)
                  _EmptyBox(message: 'No items sold today yet.')
                else
                  _ItemsTable(
                    items: stats.todayItems,
                    products: products,
                    formatPrice: _formatPrice,
                  ),

                SizedBox(height: 28.h),

                // Top selling
                Text(
                  'Top selling items',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                if (stats.topSellingItems.isEmpty)
                  _EmptyBox(message: 'No sales data yet.')
                else
                  _TopSellingList(
                    items: stats.topSellingItems,
                    products: products,
                    formatPrice: _formatPrice,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Stat card
// -----------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Today items table (with images)
// -----------------------------------------------------------------------------
class _ItemsTable extends StatelessWidget {
  const _ItemsTable({
    required this.items,
    required this.products,
    required this.formatPrice,
  });

  final List<SoldItemStat> items;
  final List<Product> products;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                SizedBox(width: 44.w),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 4,
                  child: Text('Item', style: _headerStyle()),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Revenue',
                    textAlign: TextAlign.right,
                    style: _headerStyle(),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.white12,
            indent: 14.w,
            endIndent: 14.w,
          ),
          ...items.map((item) {
            final product = findProductForStat(products, item);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                children: [
                  _ItemThumb(product: product),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatPrice(item.revenue),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
    );
  }
}

// -----------------------------------------------------------------------------
// Top selling list (with images)
// -----------------------------------------------------------------------------
class _TopSellingList extends StatelessWidget {
  const _TopSellingList({
    required this.items,
    required this.products,
    required this.formatPrice,
  });

  final List<SoldItemStat> items;
  final List<Product> products;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final rank = index + 1;
          final product = findProductForStat(products, item);

          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  color: Colors.white12,
                  indent: 14.w,
                  endIndent: 14.w,
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: rank <= 3
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _ItemThumb(product: product),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${item.quantity} sold',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatPrice(item.revenue),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small product thumbnail
// -----------------------------------------------------------------------------
class _ItemThumb extends StatelessWidget {
  const _ItemThumb({required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: product == null
            ? ColoredBox(
          color: Colors.white10,
          child: Icon(
            Icons.fastfood_rounded,
            size: 22.sp,
            color: AppColors.textSecondary,
          ),
        )
            : ProductImage(
          product: product!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty box
// -----------------------------------------------------------------------------
class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NOURISH title
// -----------------------------------------------------------------------------
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