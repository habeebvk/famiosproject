import 'dart:io';

import 'package:famioproject/models/grocery/product_model.dart';
import 'package:famioproject/services/grocery/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;

  File? _imageFile;
  String? _existingImageUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _existingImageUrl = widget.product?.imageUrl;
  }

  /// -------- Pick Image --------
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  /// -------- Upload Image --------
  Future<String> _uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref =
        FirebaseStorage.instance.ref().child('products/$fileName.jpg');

    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  /// -------- Save Product --------
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String imageUrl = _existingImageUrl ?? '';

    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      imageUrl: imageUrl,
    );

    if (widget.product == null) {
      await _productService.addProduct(product);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product added")));
    } else {
      await _productService.updateProduct(product);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product updated")));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Product" : "Add Product"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// -------- Image Preview --------
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : (_existingImageUrl != null &&
                              _existingImageUrl!.isNotEmpty)
                          ? Image.network(_existingImageUrl!,
                              fit: BoxFit.cover)
                          : const Center(
                              child: Icon(Icons.camera_alt, size: 40),
                            ),
                ),
              ),

              const SizedBox(height: 16),

              /// -------- Name --------
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter product name" : null,
              ),

              const SizedBox(height: 12),

              /// -------- Price --------
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter product price" : null,
              ),

              const SizedBox(height: 24),

              /// -------- Button --------
              ElevatedButton(
                onPressed: _loading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? "Save Changes" : "Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
