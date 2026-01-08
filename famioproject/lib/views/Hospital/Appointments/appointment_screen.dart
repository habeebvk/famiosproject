import 'package:famioproject/models/appointment.dart';
import 'package:famioproject/services/firebase_services.dart';
import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample appointments list
  List<AppointmentModel> appointments = [];
  bool _isLoading = true;

  String? _selectedDoctor;
  DateTime? _selectedDate;
  final AppointmentService _service = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _tabController = TabController(length: 2, vsync: this);
  }

Future<void> _loadAppointments() async {
  try {
    final firebaseAppointments =
        await _service.fetchAppointments();

    setState(() {
      appointments = firebaseAppointments.map((a) {
        return AppointmentModel(
          id: a.id,
          patientName: a.patientName,
          doctorName: a.doctorName,
          dateTime: a.dateTime,
          status: a.status,
        );
      }).toList();
      _isLoading = false;
    });
  } catch (e) {
    _isLoading = false;
    _showErrorSnackBar('Failed to load appointments');
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> get _doctors {
    try {
      return appointments.map((a) => a.doctorName).toSet().toList();
    } catch (e) {
      debugPrint('Error getting doctors list: $e');
      return [];
    }
  }

  List<AppointmentModel> get _pendingAppointments {
    try {
      return _filteredAppointments
          .where((a) => a.status == 'Pending')
          .toList();
    } catch (e) {
      debugPrint('Error filtering pending appointments: $e');
      return [];
    }
  }

  List<AppointmentModel> get _approvedAppointments {
    try {
      return _filteredAppointments
          .where((a) => a.status == 'Approved')
          .toList();
    } catch (e) {
      debugPrint('Error filtering approved appointments: $e');
      return [];
    }
  }

  List<AppointmentModel> get _filteredAppointments {
    try {
      return appointments.where((appointment) {
        bool matchesDoctor = _selectedDoctor == null ||
            appointment.doctorName == _selectedDoctor;
        bool matchesDate = _selectedDate == null ||
            (appointment.dateTime.year == _selectedDate!.year &&
                appointment.dateTime.month == _selectedDate!.month &&
                appointment.dateTime.day == _selectedDate!.day);
        return matchesDoctor && matchesDate;
      }).toList();
    } catch (e) {
      debugPrint('Error filtering appointments: $e');
      return [];
    }
  }

Future<void> _approveAppointment(AppointmentModel appointment) async {
  try {
    // 🔥 Update Firebase
    await _service.approveAppointment(appointment.id);

    // 🔁 Update local list
    setState(() {
      appointment.status = 'Approved';
    });

    _showSuccessSnackBar('Appointment Approved');
  } catch (e) {
    _showErrorSnackBar('Failed to approve appointment');
  }
}

Future<void> _cancelAppointment(AppointmentModel appointment) async {
  try {
    await _service.cancelAppointment(appointment.id);

    setState(() {
      appointment.status = 'Cancelled';
    });

    _showSuccessSnackBar('Appointment Cancelled');
  } catch (e) {
    _showErrorSnackBar('Failed to cancel appointment');
  }
}


  Future<void> _pickDate() async {
    try {
      DateTime now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF6366F1),
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } catch (e) {
      debugPrint('Error picking date: $e');
      _showErrorSnackBar('Failed to select date');
    }
  }

  String _formatDateOnly(DateTime dt) {
    try {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return "${twoDigits(dt.day)}/${twoDigits(dt.month)}/${dt.year}";
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  String _formatTime(DateTime dt) {
    try {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return "${twoDigits(dt.hour)}:${twoDigits(dt.minute)}";
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return '';
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6366F1),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF6366F1),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      const Text('Pending'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      const Text('Approved'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentList(_pendingAppointments, isPending: true),
                    _buildAppointmentList(_approvedAppointments, isPending: false),
                  ],
                ),
        ),

        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Doctor filter
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedDoctor,
                decoration: const InputDecoration(
                  labelText: 'Doctor',
                  labelStyle: TextStyle(color: Color(0xFF64748B)),
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF6366F1)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [null, ..._doctors].map((doctor) {
                  return DropdownMenuItem<String>(
                    value: doctor,
                    child: Text(
                      doctor ?? 'All Doctors',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctor = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            // Date filter button
            Material(
              color: _selectedDate == null 
                  ? Colors.white 
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDate == null 
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF6366F1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: _selectedDate == null 
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : _formatDateOnly(_selectedDate!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedDate == null ? FontWeight.w500 : FontWeight.w600,
                          color: _selectedDate == null 
                              ? const Color(0xFF64748B)
                              : const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(width: 8),
              Material(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentModel> appointmentList,
      {required bool isPending}) {
    if (appointmentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.event_busy : Icons.check_circle,
                size: 64,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPending
                  ? 'No pending appointments'
                  : 'No approved appointments',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? 'New appointments will appear here'
                  : 'Approved appointments will appear here',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointmentList.length,
      itemBuilder: (context, index) {
        final appointment = appointmentList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.medical_services_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                appointment.doctorName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: const Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateOnly(appointment.dateTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: const Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(appointment.dateTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:() => _approveAppointment(appointment),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelAppointment(appointment),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Approved',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

