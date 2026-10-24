
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Provider/product_provider.dart';
import '../models/product_model.dart';

import '../widgets/product_image.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _priceController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  final List<String> _categories = [
    'Burger',
    'Pizza',
    'Shawarma',
    'Biryani',
    'Cold Drinks',
  ];

  String? _category = 'Burger';

  File? _imageFile;
  String? _imagePath;

  bool _isLoading = false;

  // Pick an image from the gallery.
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedImage == null) return;

      if (!mounted) return;

      setState(() {
        _imageFile = File(pickedImage.path);
        _imagePath = pickedImage.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection failed: $e')),
      );
    }
  }

  // Copy the selected image to permanent app storage.
  Future<String> _saveImageLocally(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();

    final extension = imageFile.path.contains('.')
        ? imageFile.path.split('.').last
        : 'jpg';

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final savedImage = await imageFile.copy(
      '${appDir.path}/$fileName',
    );

    return savedImage.path;
  }

  // Clear all fields after successful saving.
  void _clearForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();

    setState(() {
      _category = 'Burger';
      _imageFile = null;
      _imagePath = null;
    });
  }

  // Save product image locally and product data to Firestore.
  Future<void> _save() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? savedImagePath;

    try {
      // 1. Save the image file on this device.
      savedImagePath = await _saveImageLocally(_imageFile!);

      // 2. Create the product model.
      final product = Product(
        name: _nameController.text.trim(),
        category: _category!,
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imagePath: savedImagePath,
        imageSource: ImageSourceType.file,
      );

      // 3. Save the local path and product details in Firestore.
      // Use the existing product provider's Firestore collection.
      await FirebaseFirestore.instance
          .collection('products')
          .add({
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'description': product.description,
        'imagePath': savedImagePath,
        'imageSource': ImageSourceType.file.name,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 4. Clear the form after the Firestore write succeeds.
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Keep the screen open so another product can be added.
      // If you want to return to the previous screen, use:
      // context.pop();
    } catch (e) {
      // Remove the copied image if saving the record failed.
      if (savedImagePath != null) {
        try {
          final file = File(savedImagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // Keep the original error for the user.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product image picker.
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  height: 190.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFFF6B00),
                    ),
                  ),
                  child: _imageFile == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: const Color(0xFFFF6B00),
                        size: 48.sp,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Select Product Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Image.file(
                      _imageFile!,
                      width: double.infinity,
                      height: 190.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Product name.
              _buildLabel('Product Name'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'Enter product name',
                  icon: Icons.fastfood,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 18.h),

              // Category.
              _buildLabel('Category'),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF1C1C1C),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'Select category',
                  icon: Icons.category,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                  setState(() => _category = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              SizedBox(height: 18.h),

              // Price.
              _buildLabel('Price'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _priceController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'Enter price',
                  icon: Icons.payments_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null || price <= 0) {
                    return 'Enter a valid price greater than zero';
                  }

                  return null;
                },
              ),

              SizedBox(height: 18.h),

              // Description.
              _buildLabel('Description'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'Enter product description',
                  icon: Icons.description_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30.h),

              // Save button.
              SizedBox(
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Save Product',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF6B00),
      ),
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B00),
        ),
      ),
    );
  }
}



