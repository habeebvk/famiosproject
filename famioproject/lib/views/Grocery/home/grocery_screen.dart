import 'package:famioproject/models/grocery/orders.dart';
import 'package:famioproject/services/grocery/order_save.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grocery Requests',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No grocery requests yet"));
          }

          final orders = snapshot.data!;

          /// ---------- ITEM COUNT (NOT QUANTITY) ----------
          final totalRequests = orders.fold<int>(
            0,
            (sum, order) => sum + order.items.length,
          );

          final acceptedRequests = orders
              .where((o) => o.status == 'accepted')
              .fold<int>(0, (sum, order) => sum + order.items.length);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------- Stats --------
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        "Total Requests",
                        totalRequests,
                        Icons.list_alt,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _statCard(
                        "Accepted",
                        acceptedRequests,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  "Pending Requests",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                /// -------- Orders List --------
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Requester: ${order.userName}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Total: ₹${order.totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),

                              /// Items
                              ...order.items.map(
                                (item) =>
                                    Text("• ${item.name} x ${item.quantity}"),
                              ),

                              const SizedBox(height: 10),

                              /// Actions & Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Status: ${order.status.toUpperCase()}",
                                    style: TextStyle(
                                      color: order.status == 'accepted'
                                          ? Colors.green
                                          : order.status == 'rejected'
                                          ? Colors.red
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (order.status == 'pending')
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            minimumSize: const Size(80, 36),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await _orderService
                                                .updateOrderStatus(
                                                  order.id,
                                                  'accepted',
                                                );
                                          },
                                          child: const Text(
                                            "Approve",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            minimumSize: const Size(80, 36),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await _orderService
                                                .updateOrderStatus(
                                                  order.id,
                                                  'rejected',
                                                );
                                          },
                                          child: const Text(
                                            "Reject",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// -------- Reusable Stat Card --------
  Widget _statCard(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
