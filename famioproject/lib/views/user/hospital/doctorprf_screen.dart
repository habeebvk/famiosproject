import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famioproject/services/auth_services.dart';
import 'package:famioproject/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AppointmentScreen extends StatefulWidget {
  final String doctorName;
  final String specialization;

  const AppointmentScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
  });

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late RazorpayService _razorpayService;
  final double standardFee = 500.0;

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

  final List<String> _morningSlots = [
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
  ];

  final List<String> _afternoonSlots = [
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM",
  ];

  // ---------------- DOCTOR CARD ----------------
  Widget _buildDoctorCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: ListTile(
        leading: const CircleAvatar(radius: 30, child: Icon(Icons.person)),
        title: Text(
          widget.doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.specialization),
      ),
    );
  }

  // ---------------- CALENDAR ----------------
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
      },
      calendarFormat: CalendarFormat.week,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ---------------- TIME SLOTS ----------------
  Widget _buildTimeSlots(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          children: slots.map((slot) {
            final isSelected = _selectedTime == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedTime = slot;
                });
              },
              selectedColor: Colors.green,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------- CONFIRM BOOKING ----------------
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // combine date + time
    final timeParts = _selectedTime!.split(' ');
    final hm = timeParts[0].split(':');
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (timeParts[1] == 'PM' && hour != 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    final userData = await AuthService().getCurrentUserData();
    final patientName = userData?['name'] ?? 'Unknown User';

    try {
      await _firestore.collection('appointments').add({
        'patientName': patientName,
        'doctorName': widget.doctorName,
        'specialization': widget.specialization,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking Confirmed! ID: ${response.paymentId ?? 'N/A'}",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to confirm booking: $e')));
    }
  }

  void showCheckoutDialog() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🏥 Checkout Summary"),
        content: Text(
          "Consultation Fee is ₹${standardFee.toStringAsFixed(2)}",
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
            onPressed: () {
              Navigator.pop(context);
              _razorpayService.openCheckout(
                amount: standardFee,
                description: 'Doctor Consultation Payment',
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Appointment"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDoctorCard(),
            _buildCalendar(),
            const SizedBox(height: 16),
            _buildTimeSlots("Morning", _morningSlots),
            _buildTimeSlots("Afternoon", _afternoonSlots),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: showCheckoutDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                backgroundColor: Colors.green,
              ),
              child: const Text("Confirm Booking"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
