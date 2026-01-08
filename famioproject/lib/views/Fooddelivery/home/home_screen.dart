import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/models/fooddelivery/food_order.dart';
import 'package:flutter/material.dart';
import 'package:famioproject/services/fooddelivery/food_service.dart';

class FoodRequestDashboard extends StatefulWidget {
  const FoodRequestDashboard({super.key});

  @override
  State<FoodRequestDashboard> createState() => _FoodRequestDashboardState();
}

class _FoodRequestDashboardState extends State<FoodRequestDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FoodProductService _service = FoodProductService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// Accept an order
  void _acceptOrder(FoodOrder order) async {
    await _service.updateOrderStatus(order.id, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${order.id.substring(0, 6)} accepted ✅"),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {}); // refresh UI
  }

  /// Reject an order
  void _rejectOrder(FoodOrder order) async {
    await _service.updateOrderStatus(order.id, false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${order.id.substring(0, 6)} rejected ❌"),
        backgroundColor: Colors.redAccent,
      ),
    );
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {}, icon: const Icon(Icons.arrow_back, color: Colors.white)),
        elevation: 0,
        title: const Text(
          '🍴 Food Delivery',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<List<FoodOrder>>(
        stream: _service.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          final orders = snapshot.data!;
          final acceptedOrders = orders.where((o) => o.accepted == true).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassCard(
                        title: "Total Requests",
                        count: orders.length,
                        color1: const Color(0xFF56CCF2),
                        color2: const Color(0xFF2F80ED),
                        icon: Icons.fastfood_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGlassCard(
                        title: "Accepted",
                        count: acceptedOrders.length,
                        color1: const Color(0xFF6EE7B7),
                        color2: const Color(0xFF3B82F6),
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// TabBar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.green[700],
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.list_alt), text: "All Requests"),
                      Tab(icon: Icon(Icons.done_all_rounded), text: "Accepted"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestList(orders, showActions: true), // All Requests
                      _buildRequestList(acceptedOrders, showActions: false), // Accepted only
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build list of orders
  Widget _buildRequestList(List<FoodOrder> orders, {bool showActions = true}) {
    if (orders.isEmpty) {
      return const Center(
        child: Text("No orders available.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        Widget trailingWidget;

        if (order.accepted == null && showActions) {
          // Pending → show both approve and reject buttons
          trailingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _acceptOrder(order),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.redAccent),
                onPressed: () => _rejectOrder(order),
              ),
            ],
          );
        } else if (order.accepted == true) {
          // Accepted
          trailingWidget = const Icon(Icons.check_circle, color: Colors.green);
        } else {
          // Rejected
          trailingWidget = const Icon(Icons.cancel, color: Colors.redAccent);
        }

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 14),
          child: ListTile(
            title: Text("Order #${order.id.substring(0, 6)}"),
            subtitle: Text(
              "Items: ${order.items.map((e) => e['name']).join(', ')}\n"
              "Total: ₹${order.total.toStringAsFixed(2)}\n"
              "Address: ${order.address}",
            ),
            trailing: trailingWidget,
          ),
        );
      },
    );
  }

  /// Glass Stat Card
  Widget _buildGlassCard({
    required String title,
    required int count,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text("$count",
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
