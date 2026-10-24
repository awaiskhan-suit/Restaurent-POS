// lib/bottom_navigation/bottom_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';

class _NavData {
  const _NavData(
      this.label,
      this.icon,
      this.activeIcon,
      );

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const List<_NavData> _items = [
  _NavData(
    'Dashboard',
    Icons.dashboard_outlined,
    Icons.dashboard_rounded,
  ),
  _NavData(
    'Menu',
    Icons.restaurant_menu_outlined,
    Icons.restaurant_menu_rounded,
  ),

  _NavData(
    'Orders',
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
  ),
  _NavData(
    'Cart',
    Icons.shopping_cart_outlined,
    Icons.shopping_cart_rounded,
  ),

];

class MenuBottomNav extends StatelessWidget {
  const MenuBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.header,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: AppColors.header,
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              return Expanded(
                child: _NavItem(
                  key: ValueKey(item.label),
                  data: item,
                  selected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _NavData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: selected ? 22.w : 0,
                  height: 3.h,
                  margin: EdgeInsets.only(bottom: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                AnimatedScale(
                  scale: selected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      selected ? data.activeIcon : data.icon,
                      key: ValueKey<bool>(selected),
                      size: 22.sp,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
