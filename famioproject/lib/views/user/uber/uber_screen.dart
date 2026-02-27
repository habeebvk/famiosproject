import 'package:famioproject/services/cars/uber_booking.dart';
import 'package:flutter/material.dart';
import 'package:famioproject/services/razorpay_service.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UberBookingPage extends StatefulWidget {
  const UberBookingPage({super.key});

  @override
  _UberBookingPageState createState() => _UberBookingPageState();
}

class _UberBookingPageState extends State<UberBookingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropOffController = TextEditingController();

  final FocusNode pickupFocusNode = FocusNode();
  final FocusNode dropOffFocusNode = FocusNode();

  final UberBookingService _bookingService = UberBookingService();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  late RazorpayService _razorpayService;
  final double baseRideFee = 200.0;

  // IMPORTANT: Replace with your actual Google Maps API Key
  final String googleMapsApiKey = "AIzaSyCnXk2YpbWjr5UgTFFflUgfDsagIqwwObE";

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    nameController.dispose();
    pickupController.dispose();
    dropOffController.dispose();
    pickupFocusNode.dispose();
    dropOffFocusNode.dispose();
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

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final DateTime finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    try {
      await _bookingService.addBooking(
        name: nameController.text.trim(),
        pickup: pickupController.text.trim(),
        dropOff: dropOffController.text.trim(),
        pickupDateTime: finalDateTime,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Ride Requested"),
          content: Text(
            "Hi ${nameController.text},\n\nYour ride from '${pickupController.text}' to '${dropOffController.text}' is scheduled for $formattedDateTime.\n\nPayment ID: ${response.paymentId ?? 'N/A'}",
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to request ride: $e")));
    }
  }

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
      appBar: AppBar(title: const Text("Uber Booking"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// 🔹 NAME FIELD
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// 🔹 PICKUP LOCATION
            GooglePlaceAutoCompleteTextField(
              textEditingController: pickupController,
              googleAPIKey: googleMapsApiKey,
              inputDecoration: InputDecoration(
                labelText: "Current Location",
                prefixIcon: const Icon(Icons.my_location),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              debounceTime: 800,
              focusNode: pickupFocusNode,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                pickupController.text = prediction.description ?? "";
              },
              itemClick: (Prediction prediction) {
                pickupController.text = prediction.description ?? "";
                pickupController.selection = TextSelection.fromPosition(
                  TextPosition(offset: pickupController.text.length),
                );
              },
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 7),
                      Expanded(child: Text(prediction.description ?? "")),
                    ],
                  ),
                );
              },
              seperatedBuilder: const Divider(),
              isCrossBtnShown: true,
            ),
            const SizedBox(height: 16),

            /// 🔹 DROP LOCATION
            GooglePlaceAutoCompleteTextField(
              textEditingController: dropOffController,
              googleAPIKey: googleMapsApiKey,
              inputDecoration: InputDecoration(
                labelText: "Drop-off Location",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              debounceTime: 800,
              focusNode: dropOffFocusNode,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                dropOffController.text = prediction.description ?? "";
              },
              itemClick: (Prediction prediction) {
                dropOffController.text = prediction.description ?? "";
                dropOffController.selection = TextSelection.fromPosition(
                  TextPosition(offset: dropOffController.text.length),
                );
              },
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 7),
                      Expanded(child: Text(prediction.description ?? "")),
                    ],
                  ),
                );
              },
              seperatedBuilder: const Divider(),
              isCrossBtnShown: true,
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
                  backgroundColor: const Color.fromARGB(255, 248, 246, 129),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      pickupController.text.isEmpty ||
                      dropOffController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields.")),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text("🚕 Checkout Summary"),
                      content: Text(
                        "Your estimated ride fee is ₹${baseRideFee.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _razorpayService.openCheckout(
                              amount: baseRideFee,
                              description: 'Uber Ride Payment',
                            );
                          },
                          child: const Text("Confirm"),
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
