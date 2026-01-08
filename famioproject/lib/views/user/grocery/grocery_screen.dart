import 'package:famioproject/models/grocery/product_model.dart';
import 'package:famioproject/services/grocery/order_save.dart';
import 'package:famioproject/services/grocery/product.dart';
import 'package:flutter/material.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  final Map<String, int> _cart = {}; // productId -> quantity
  List<Product> _products = [];

  double get totalPrice => _cart.entries.fold(0, (sum, entry) {
        final product = _products.firstWhere((p) => p.id == entry.key);
        return sum + product.price * entry.value;
      });

  void incrementItem(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void decrementItem(String productId) {
    setState(() {
      if (_cart[productId] != null && _cart[productId]! > 0) {
        _cart[productId] = _cart[productId]! - 1;
      }
    });
  }

  void showCheckoutDialog() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one item to checkout.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🛍️ Checkout Summary"),
        content: Text(
          "Your total bill is ₹${totalPrice.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await _orderService.createOrder(
                  products: _products,
                  cart: _cart,
                  totalAmount: totalPrice,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Order placed successfully!")),
                );

                setState(() {
                  _cart.clear();
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: const Text(
          "🛒 Grocery Shop",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          _products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final product = _products[index];
              final qty = _cart[product.id] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              )
                            : const Icon(
                                Icons.shopping_bag,
                                size: 60,
                                color: Colors.green,
                              ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text("₹${product.price.toStringAsFixed(2)}"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () =>
                                    decrementItem(product.id),
                              ),
                              Text(qty.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    incrementItem(product.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: showCheckoutDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.all(14),
          ),
          child: Text(
            "Checkout ₹${totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
