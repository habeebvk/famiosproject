import 'dart:io';
import 'package:famioproject/models/fooddelivery/food_product.dart';
import 'package:famioproject/services/fooddelivery/food_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class FoodProductPage extends StatefulWidget {
  const FoodProductPage({super.key});

  @override
  State<FoodProductPage> createState() => _FoodProductPageState();
}

class _FoodProductPageState extends State<FoodProductPage> {
  final FoodProductService _service = FoodProductService();
  final List<FoodProduct> _products = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();


  File? _selectedImage;
  bool _available = true;
  FoodProduct? _editingProduct;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _openAddEditDialog({FoodProduct? product}) {
    if (product != null) {
      _editingProduct = product;
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _categoryController.text = product.category;
      _available = product.available;
    } else {
      _editingProduct = null;
      _nameController.clear();
      _priceController.clear();
      _categoryController.clear();
      _selectedImage = null;
      _available = true;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product == null ? "Add Product" : "Edit Product"),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      backgroundColor: Colors.green.shade100,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt,
                              size: 30, color: Colors.green)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Product Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter product name" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Price",
                      prefixText: "₹ ",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter price" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Available"),
                    activeColor: Colors.green,
                    value: _available,
                    onChanged: (v) => setState(() => _available = v),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(product == null ? "Add" : "Update"),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              if (_editingProduct == null) {
                /// ➕ ADD
                await _service.addProduct(
                  name: _nameController.text,
                  price: double.parse(_priceController.text),
                  imageFile: _selectedImage,
                  category: _categoryController.text,
                  available: _available,
                );
              } else {
                /// ✏️ UPDATE
                await _service.updateProduct(
                  id: _editingProduct!.id,
                  name: _nameController.text,
                  price: double.parse(_priceController.text),
                  imageFile: _selectedImage,
                  category: _categoryController.text,
                  available: _available,
                  oldImageUrl: _editingProduct!.imageUrl,
                );
              }

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _products.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text(" Products",style: TextStyle(color: Colors.white,fontSize: 18),),
        backgroundColor: Colors.green,
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _openAddEditDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
            ),
          )
        ],
      ),
      body:StreamBuilder<List<FoodProduct>>(
        stream: _service.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products added"));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];

              return Card(
                child: ListTile(
                  leading: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood),
                  title: Text(product.name),
                  subtitle: Text(
                    "₹${product.price} • ${product.category} • ${product.available ? "Available" : "Unavailable"}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _openAddEditDialog(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _service.deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}