import 'package:flutter/material.dart';
import 'package:famioproject/models/fooddelivery/food_product.dart';
import 'package:famioproject/services/fooddelivery/food_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famioproject/services/auth_services.dart';
import 'dart:io';

class FoodPurchasePage extends StatefulWidget {
  @override
  _FoodPurchasePageState createState() => _FoodPurchasePageState();
}

class _FoodPurchasePageState extends State<FoodPurchasePage> {
  final FoodProductService _service = FoodProductService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  /// quantity map (productId → qty)
  final Map<String, int> _quantity = {};

  double get totalPrice =>
      _products.fold(0, (sum, p) => sum + (p.price * (_quantity[p.id] ?? 0)));

  List<FoodProduct> _products = [];

  void increment(FoodProduct p) {
    setState(() {
      _quantity[p.id] = (_quantity[p.id] ?? 0) + 1;
    });
  }

  void decrement(FoodProduct p) {
    setState(() {
      if ((_quantity[p.id] ?? 0) > 0) {
        _quantity[p.id] = _quantity[p.id]! - 1;
      }
    });
  }

  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _razorpayService = RazorpayService();
    _razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  Future<void> _loadUserData() async {
    try {
      final data = await AuthService().getCurrentUserData();
      if (mounted) {
        setState(() {
          _userData = data;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose Profile Photo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      await _uploadImage(File(image.path));
                    }
                  },
                ),
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      await _uploadImage(File(image.path));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: Icon(icon, color: Colors.deepOrange, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileImageUrl': downloadUrl},
      );

      await _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External wallet selected: ${response.walletName}"),
      ),
    );
  }

  /// 🔹 PLACE ORDER AND SAVE TO FIRESTORE
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final orderedItems = _products
        .where((p) => (_quantity[p.id] ?? 0) > 0)
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'price': p.price,
            'quantity': _quantity[p.id],
            'total': p.price * (_quantity[p.id] ?? 0),
          },
        )
        .toList();

    // 🔹 SAVE ORDER TO FIRESTORE
    try {
      // NOTE: Might need to pass response.paymentId if food_service supports it,
      // but assuming placeOrder stays the same for now based on service structure.
      await _service.placeOrder(orderedItems, totalPrice);

      // Show order summary
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Order Placed! \nID: ${response.paymentId ?? 'N/A'}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...orderedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "${item['name']} x ${item['quantity']} = ₹${(item['total'] as double).toStringAsFixed(2)}",
                  ),
                ),
              ),
              const Divider(),
              Text(
                "Total: ₹${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _quantity.clear();
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
    }
  }

  void showCheckoutDialog() {
    if (totalPrice == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one item.")));
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
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _razorpayService.openCheckout(
                amount: totalPrice,
                description: 'Food Order Payment',
              );
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
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text(
          "🍴 Food Order",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    backgroundImage: _userData?['profileImageUrl'] != null
                        ? NetworkImage(_userData!['profileImageUrl'])
                        : null,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : (_userData?['profileImageUrl'] == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.deepOrange,
                      size: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),

      /// 🔥 FIRESTORE DATA
      body: StreamBuilder<List<FoodProduct>>(
        stream: _service.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No food items available"));
          }

          _products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final item = _products[index];
              final qty = _quantity[item.id] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade100,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood, size: 36),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    "₹ ${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => decrement(item),
                        ),
                        Text(
                          qty.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => increment(item),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      /// 🧾 BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: ₹${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text("Place Order"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: showCheckoutDialog,
            ),
          ],
        ),
      ),
    );
  }
}
