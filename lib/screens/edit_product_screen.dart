
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../Provider/product_image_provider.dart';
import '../Provider/product_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_image.dart';

class EditProductScreen extends ConsumerStatefulWidget {
final Product product;

const EditProductScreen({
super.key,
required this.product,
});

@override
ConsumerState<EditProductScreen> createState() =>
_EditProductScreenState();
}

class _EditProductScreenState
extends ConsumerState<EditProductScreen> {
final _formKey = GlobalKey<FormState>();

late final TextEditingController _nameCtrl;
late final TextEditingController _priceCtrl;
late final TextEditingController _descCtrl;

late String _category;
String? _imagePath;
late ImageSourceType _imageSource;

File? _newImageFile;
bool _isLoading = false;

final List<String> _categories = [
'Burger',
'Pizza',
'Shawarma',
'Biryani',
'Cold Drinks',
];

static const Color _backgroundColor = Color(0xFF0D0D0D);
static const Color _fieldColor = Color(0xFF1A1A1A);
static const Color _primaryColor = Color(0xFFFF6B00);

@override
void initState() {
super.initState();

final product = widget.product;

_nameCtrl = TextEditingController(text: product.name);
_priceCtrl = TextEditingController(
text: product.price.toString(),
);
_descCtrl = TextEditingController(
text: product.description,
);

_category = product.category;
_imagePath = product.imagePath;
_imageSource = product.imageSource;

if (_category.isNotEmpty &&
!_categories.contains(_category)) {
_categories.add(_category);
}
}

@override
void dispose() {
_nameCtrl.dispose();
_priceCtrl.dispose();
_descCtrl.dispose();
super.dispose();
}

// Pick an image from the gallery.
Future<void> _pickImage() async {
try {
final XFile? pickedFile = await ImagePicker().pickImage(
source: ImageSource.gallery,
imageQuality: 85,
);

if (pickedFile == null || !mounted) return;

setState(() {
_newImageFile = File(pickedFile.path);
_imagePath = pickedFile.path;
_imageSource = ImageSourceType.file;
});
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Unable to select image: $e'),
backgroundColor: Colors.redAccent,
),
);
}
}

// Copy the image into permanent app-local storage.
Future<String> _saveImageLocally(File imageFile) async {
final directory = await getApplicationDocumentsDirectory();

final fileName =
'product_${DateTime.now().microsecondsSinceEpoch}.jpg';

final savedFile = await imageFile.copy(
'${directory.path}/$fileName',
);

return savedFile.path;
}

Future<void> _save() async {
if (!_formKey.currentState!.validate()) return;

if (_imagePath == null || _imagePath!.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please select a product image'),
backgroundColor: Colors.redAccent,
),
);
return;
}

// The product ID is nullable in your Product model.
final String? productId = widget.product.id;

if (productId == null || productId.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Product ID is missing. Please reload the product and try again.',
),
backgroundColor: Colors.redAccent,
),
);
return;
}

setState(() => _isLoading = true);

String? newlySavedImagePath;

try {
String finalImagePath = _imagePath!;
ImageSourceType finalImageSource = _imageSource;

// Only copy a file when the user chooses a new image.
if (_newImageFile != null) {
finalImagePath = await _saveImageLocally(_newImageFile!);
newlySavedImagePath = finalImagePath;
finalImageSource = ImageSourceType.file;
}

final updatedProduct = Product(
id: productId,
name: _nameCtrl.text.trim(),
category: _category,
price: double.parse(_priceCtrl.text.trim()),
description: _descCtrl.text.trim(),
imagePath: finalImagePath,
imageSource: finalImageSource,
createdAt: widget.product.createdAt,
);

// This call must match your provider's method signature:
// updateProduct(String productId, Product product)
await ref
    .read(productListProvider.notifier)
    .updateProduct(productId, updatedProduct);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Product updated successfully!'),
backgroundColor: Colors.green,
),
);

context.pop();
} catch (e) {
// Delete the newly copied image if the database update fails.
if (newlySavedImagePath != null) {
try {
final file = File(newlySavedImagePath);
if (await file.exists()) {
await file.delete();
}
} catch (_) {
// Ignore cleanup errors.
}
}

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error updating product: $e'),
backgroundColor: Colors.redAccent,
),
);
} finally {
if (mounted) {
setState(() => _isLoading = false);
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: _backgroundColor,
appBar: AppBar(
backgroundColor: _backgroundColor,
centerTitle: true,
elevation: 0,
leading: IconButton(
icon: const Icon(
Icons.arrow_back_ios_new,
color: Colors.white,
),
onPressed: _isLoading ? null : () => context.pop(),
),
title: Text(
'Edit Product',
style: TextStyle(
color: Colors.white,
fontSize: 18.sp,
),
),
),
body: SingleChildScrollView(
padding: EdgeInsets.all(20.w),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
// Product image
GestureDetector(
onTap: _isLoading ? null : _pickImage,
child: Container(
height: 200.h,
decoration: BoxDecoration(
color: _fieldColor,
borderRadius: BorderRadius.circular(16.r),
border: Border.all(color: Colors.white12),
),
child: _imagePath == null ||
_imagePath!.isEmpty
? Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.add_a_photo_rounded,
size: 48.sp,
color: Colors.white38,
),
SizedBox(height: 8.h),
Text(
'Tap to select image',
style: TextStyle(
color: Colors.white38,
fontSize: 14.sp,
),
),
],
)
    : ClipRRect(
borderRadius: BorderRadius.circular(16.r),
child: Stack(
fit: StackFit.expand,
children: [
ProductImage(
product: Product(
id: widget.product.id,
name: widget.product.name,
category: _category,
price: widget.product.price,
description:
widget.product.description,
imagePath: _imagePath!,
imageSource: _imageSource,
),
height: 200.h,
),
Positioned(
top: 10.h,
right: 10.w,
child: Container(
padding: EdgeInsets.all(8.w),
decoration: const BoxDecoration(
color: Colors.black54,
shape: BoxShape.circle,
),
child: Icon(
Icons.edit,
color: Colors.white,
size: 20.sp,
),
),
),
],
),
),
),
),

SizedBox(height: 24.h),

// Product name
_label('Product Name'),
TextFormField(
controller: _nameCtrl,
enabled: !_isLoading,
style: const TextStyle(color: Colors.white),
textCapitalization: TextCapitalization.words,
decoration: _inputDecoration(
'Enter product name',
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter product name';
}
return null;
},
),

SizedBox(height: 16.h),

// Category
_label('Category'),
DropdownButtonFormField<String>(
value: _category.isEmpty ? null : _category,
dropdownColor: _fieldColor,
style: const TextStyle(color: Colors.white),
decoration: _inputDecoration('Select category'),
items: _categories.map((category) {
return DropdownMenuItem<String>(
value: category,
child: Text(category),
);
}).toList(),
validator: (value) =>
value == null ? 'Please select a category' : null,
onChanged: _isLoading
? null
    : (value) {
if (value != null) {
setState(() => _category = value);
}
},
),

SizedBox(height: 16.h),

// Price
_label('Price'),
TextFormField(
controller: _priceCtrl,
enabled: !_isLoading,
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
style: const TextStyle(color: Colors.white),
decoration: _inputDecoration('0.00'),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter price';
}

final price = double.tryParse(value.trim());

if (price == null || price <= 0) {
return 'Enter a valid price';
}

return null;
},
),

SizedBox(height: 16.h),

// Description
_label('Description'),
TextFormField(
controller: _descCtrl,
enabled: !_isLoading,
maxLines: 4,
style: const TextStyle(color: Colors.white),
decoration: _inputDecoration(
'Product description...',
),
),

SizedBox(height: 32.h),

// Update button
ElevatedButton(
onPressed: _isLoading ? null : _save,
style: ElevatedButton.styleFrom(
backgroundColor: _primaryColor,
foregroundColor: Colors.white,
disabledBackgroundColor:
_primaryColor.withOpacity(0.5),
padding: EdgeInsets.symmetric(vertical: 16.h),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30.r),
),
),
child: _isLoading
? SizedBox(
height: 22.h,
width: 22.h,
child: const CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : Text(
'Update Product',
style: TextStyle(
fontSize: 16.sp,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
),
);
}

Widget _label(String text) {
return Padding(
padding: EdgeInsets.only(bottom: 8.h),
child: Text(
text,
style: TextStyle(
color: Colors.white70,
fontSize: 13.sp,
fontWeight: FontWeight.w500,
),
),
);
}

InputDecoration _inputDecoration(String? hint) {
return InputDecoration(
hintText: hint,
hintStyle: const TextStyle(color: Colors.white38),
filled: true,
fillColor: _fieldColor,
contentPadding: EdgeInsets.symmetric(
horizontal: 16.w,
vertical: 14.h,
),
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
borderSide: const BorderSide(color: _primaryColor),
),
);
}
}



