import 'package:famioproject/services/cars/uber_booking.dart';
import 'package:flutter/material.dart';

class UberBookingPage extends StatefulWidget {
  const UberBookingPage({super.key});

  @override
  _UberBookingPageState createState() => _UberBookingPageState();
}

class _UberBookingPageState extends State<UberBookingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropOffController = TextEditingController();

  final UberBookingService _bookingService = UberBookingService();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );

      if (time != null) {
        setState(() {
          selectedDate = date;
          selectedTime = time;
        });
      }
    }
  }

  String get formattedDateTime {
    final date =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    final time =
        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
    return "$date at $time";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uber Booking"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 MAP PLACEHOLDER
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Map View",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// 🔹 NAME FIELD
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            /// 🔹 PICKUP LOCATION
            TextField(
              controller: pickupController,
              decoration: InputDecoration(
                labelText: "Pickup Location",
                prefixIcon: const Icon(Icons.my_location),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            /// 🔹 DROP LOCATION
            TextField(
              controller: dropOffController,
              decoration: InputDecoration(
                labelText: "Drop-off Location",
                prefixIcon: const Icon(Icons.location_on),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            /// 🔹 DATE & TIME
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text("Pickup Time"),
              subtitle: Text(formattedDateTime),
              trailing: TextButton(
                onPressed: () => _pickDateTime(context),
                child: const Text("Change"),
              ),
            ),
            const SizedBox(height: 20),

            /// 🔹 REQUEST BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_taxi),
                label: const Text("Request Ride"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      const Color.fromARGB(255, 248, 246, 129),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      pickupController.text.isEmpty ||
                      dropOffController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all fields."),
                      ),
                    );
                    return;
                  }

                  final DateTime finalDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  await _bookingService.addBooking(
                    name: nameController.text.trim(),
                    pickup: pickupController.text.trim(),
                    dropOff: dropOffController.text.trim(),
                    pickupDateTime: finalDateTime,
                  );

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Ride Requested"),
                      content: Text(
                        "Hi ${nameController.text},\n\nYour ride from '${pickupController.text}' to '${dropOffController.text}' is scheduled for $formattedDateTime.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            nameController.clear();
                            pickupController.clear();
                            dropOffController.clear();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
