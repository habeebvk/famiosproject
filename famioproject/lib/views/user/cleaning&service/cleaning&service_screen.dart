import 'package:famioproject/models/cleaning/service.dart';
import 'package:famioproject/services/cleaning/service_clean.dart';
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ServiceFirestoreService _service = ServiceFirestoreService();

  final TextEditingController addressController = TextEditingController();

  /// ✅ STORE SELECTED SERVICE IDS
  final Set<String> selectedServiceIds = {};

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDate = date;
          selectedTime = time;
        });
      }
    }
  }

  /// ✅ TOTAL PRICE BASED ON SELECTED IDS
  double _totalPrice(List<Service> services) {
    return services
        .where((s) => selectedServiceIds.contains(s.id))
        .fold(0.0, (sum, s) => sum + s.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Booking"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Service>>(
        stream: _service.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No services available"));
          }

          final services = snapshot.data!;
          final total = _totalPrice(services);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                /// ✅ SERVICES WITH PERSISTENT SELECTION
                ...services.map((service) {
                  final isSelected =
                      selectedServiceIds.contains(service.id);

                  return CheckboxListTile(
                    title: Text(service.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.description),
                        Text("Price: ₹${service.price.toStringAsFixed(2)}"),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedServiceIds.add(service.id);
                        } else {
                          selectedServiceIds.remove(service.id);
                        }
                      });
                    },
                  );
                }),

                const SizedBox(height: 20),

                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Enter your address",
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text("Select Date & Time"),
                  subtitle: Text(
                    selectedDate != null && selectedTime != null
                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - ${selectedTime!.format(context)}"
                        : "Not selected",
                  ),
                  trailing: ElevatedButton(
                    onPressed: _selectDateTime,
                    child: const Text("Pick"),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Price:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                   onPressed: selectedServiceIds.isEmpty
                    ? null
                    : () async {
                        if (addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enter address")),
                          );
                          return;
                        }

                        if (selectedDate == null || selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Select date & time")),
                          );
                          return;
                        }

                        final selectedServices = services
                            .where((s) => selectedServiceIds.contains(s.id))
                            .toList();

                        final total = _totalPrice(services);

                        await _service.addBooking(
                          address: addressController.text.trim(),
                          date: selectedDate!,
                          time: selectedTime!.format(context),
                          totalPrice: total,
                          services: selectedServices,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking Confirmed")),
                        );

                        setState(() {
                          selectedServiceIds.clear();
                          addressController.clear();
                          selectedDate = null;
                          selectedTime = null;
                        });
                      },

                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Book Now"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
