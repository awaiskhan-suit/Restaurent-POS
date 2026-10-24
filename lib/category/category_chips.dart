import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';
import '../animations/left_to_right.dart';

class _CategoryItem {
  const _CategoryItem({
    required this.label,
    required this.category,
    this.imagePath,
    this.icon,
  });

  final String label;
  final String category;
  final String? imagePath;
  final IconData? icon;
}

const List<_CategoryItem> _items = [
  _CategoryItem(
    label: 'All',
    category: 'All',
    icon: Icons.restaurant_rounded,
  ),
  _CategoryItem(
    label: 'Burgers',
    category: 'Burger',
    imagePath: 'assets/images/burger_icon.png',
  ),
  _CategoryItem(
    label: 'Pizza',
    category: 'Pizza',
    imagePath: 'assets/images/pizza_icon.jpg',
  ),
  _CategoryItem(
    label: 'Shawarma',
    category: 'Shawarma',
    imagePath: 'assets/images/shawarma_icon.jpg',
  ),
  _CategoryItem(
    label: 'Biryani',
    category: 'Biryani',
    imagePath: 'assets/images/biryani_icon.jpg',
  ),
  _CategoryItem(
    label: 'Drinks',
    category: 'Cold Drinks',
    imagePath: 'assets/images/pepsi_icon.jpg',
  ),
];

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final item = _items[index];

          return SlideInFromLeft(
            delay: Duration(milliseconds: index * 70),
            child: _CategoryChip(
              item: item,
              isSelected: item.category == selected,
              onTap: () => onSelected(item.category),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _CategoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 68.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 60.w,
                height: 60.w,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white24,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? const [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                      : const [],
                ),
                child: ClipOval(
                  child: Center(
                    child: item.imagePath != null
                        ? Image.asset(
                      item.imagePath!,
                      width: 54.w,
                      height: 54.w,
                      fit: BoxFit.cover,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Icon(
                          Icons.broken_image_outlined,
                          size: 27.sp,
                          color: AppColors.primary,
                        );
                      },
                    )
                        : Icon(
                      item.icon ?? Icons.restaurant_rounded,
                      size: 27.sp,
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
