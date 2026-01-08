import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> _morningSlots = [
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM"
  ];

  final List<String> _afternoonSlots = [
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM"
  ];

  // ---------------- DOCTOR CARD ----------------
    Widget _buildDoctorCard() {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: ListTile(
          leading: const CircleAvatar(
            radius: 30,
            child: Icon(Icons.person),
          ),
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
      headerStyle:
          const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      calendarStyle: const CalendarStyle(
        todayDecoration:
            BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
        selectedDecoration:
            BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      ),
    );
  }

  // ---------------- TIME SLOTS ----------------
  Widget _buildTimeSlots(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
Future<void> _confirmBooking() async {
  if (_selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a time slot')),
    );
    return;
  }

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

await _firestore.collection('appointments').add({
  'patientName': 'John Doe', // replace later with auth user
  'doctorName': widget.doctorName,
  'specialization': widget.specialization,
  'dateTime': Timestamp.fromDate(dateTime),
  'status': 'Pending',
  'createdAt': FieldValue.serverTimestamp(),
});


  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Booking Confirmed!')),
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
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
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
