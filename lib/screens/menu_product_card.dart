
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';
import '../Provider/product_image_provider.dart';
import '../animations/left_to_right.dart';
import '../models/product_model.dart';
import '../widgets/product_image.dart';

class MenuProductCard extends StatelessWidget {
  const MenuProductCard({
    super.key,
    required this.product,
    required this.index,
    required this.onDelete,
    required this.onOpen,
  });

  final Product product;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  String get _price =>
      'Rs ${product.price.toStringAsFixed(product.price % 1 == 0 ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: SizedBox(
        // Increased card height for larger product images.
        height: 300.h,
        width: double.infinity,
        child: GestureDetector(
          onDoubleTap: onOpen,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Product image with left-to-right animation.
                SlideInFromLeft(
                  delay: Duration(
                    milliseconds: index.clamp(0, 4) * 100,
                  ),
                  child: ProductImage(
                    product: product,
                    fit: BoxFit.cover,
                  ),
                ),

                // Gradient overlay for readable text.
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.scrimTop,
                          Colors.transparent,
                          AppColors.scrimBottom,
                        ],
                        stops: [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),

                // Delete button.
                Positioned(
                  top: 14,
                  right: 14,
                  child: Tooltip(
                    message: 'Delete ${product.name}',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onDelete,
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glassFill,
                            border: Border.all(
                              color: AppColors.glassBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 23.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Product name and price.
                Positioned(
                  left: 20.w,
                  right: 82.w,
                  bottom: 20.h,
                  child: IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _price,
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.95,
                            ),
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Edit button.
                Positioned(
                  right: 16.w,
                  bottom: 18.h,
                  child: Tooltip(
                    message: 'Edit ${product.name}',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onOpen,
                        child: Container(
                          width: 54.w,
                          height: 54.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGlow,
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.textOnPrimary,
                            size: 26.sp,
                          ),
                        ),
                      ),
                    ),
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
