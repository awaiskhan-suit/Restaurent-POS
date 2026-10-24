import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductImage extends StatelessWidget {
  final Product product;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // 1. First try Network Image (Firebase Storage URL)
    if (product.imageSource == ImageSourceType.network &&
        product.imagePath.isNotEmpty) {
      return Image.network(
        product.imagePath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade800,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // If network fails → try local image
          return _buildLocalImage();
        },
      );
    }

    // 2. Try Local Image
    return _buildLocalImage();
  }

  Widget _buildLocalImage() {
    if (product.imageSource == ImageSourceType.file &&
        product.imagePath.isNotEmpty) {
      final file = File(product.imagePath);

      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      }
    }

    // 3. No image available
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade800,
      child: Icon(
        Icons.image_not_supported_rounded,
        size: (height != null && height! < 100) ? 30 : 50,
        color: Colors.white38,
      ),
    );
  }
}

