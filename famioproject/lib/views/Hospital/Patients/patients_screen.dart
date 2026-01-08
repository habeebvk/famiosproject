import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  final CollectionReference patientsRef =
      FirebaseFirestore.instance.collection('patients');

  // ---------------- VIEW DETAILS ----------------
  void _addPatient() {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final doctorController = TextEditingController();
  final diseaseController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.teal.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add New Patient',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // NAME
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Patient Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // DISEASE
                TextField(
                  controller: diseaseController,
                  decoration: InputDecoration(
                    labelText: 'Disease/Condition',
                    prefixIcon:
                        const Icon(Icons.local_hospital_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // AGE
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // DOCTOR
                TextField(
                  controller: doctorController,
                  decoration: InputDecoration(
                    labelText: 'Assigned Doctor',
                    prefixIcon:
                        const Icon(Icons.medical_services_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // DATE & TIME PICKER
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(selectedDateTime),
                      );

                      if (time != null) {
                        setDialogState(() {
                          selectedDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.teal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admission Date & Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(selectedDateTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            ageController.text.isEmpty ||
                            doctorController.text.isEmpty ||
                            diseaseController.text.isEmpty) {
                          return;
                        }

                        await patientsRef.add({
                          'name': nameController.text.trim(),
                          'age':
                              int.tryParse(ageController.text) ?? 0,
                          'disease':
                              diseaseController.text.trim(),
                          'assignedDoctor':
                              doctorController.text.trim(),
                          'admissionDateTime':
                              Timestamp.fromDate(selectedDateTime),
                          'createdAt':
                              FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Patient added successfully!'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Patient'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  void _viewPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      patient['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.cake_outlined, 'Age', '${patient['age']} years'),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.local_hospital_outlined, 'Disease', patient['disease']),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.medical_services_outlined, 'Assigned Doctor', patient['assignedDoctor']),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Admission',
                _formatDateTime(
                  (patient['admissionDateTime'] as Timestamp).toDate(),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal.shade700, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- FORMAT DATE ----------------

  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year} "
        "${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}";
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: patientsRef.snapshots(),
      builder: (context, snapshot) {
      // 🔹 STILL CONNECTING
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 ERROR
    if (snapshot.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${snapshot.error}'),
        ),
      );
    }

    // 🔹 NO DATA
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No patients found')),
      );
    }

    final docs = snapshot.data!.docs;
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
            title: const Text(
              'Patient Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
            elevation: 0,
          ),
          body: Column(
  children: [
    // HEADER + ADD BUTTON
    Container(
      decoration: const BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Patients: ${docs.length}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
                  onPressed: _addPatient, // ✅ FIXED
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20)
                    ),
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: const Text('Add New Patient'),
                ),
        ],
      ),
    ),

    // PATIENT LIST
    Expanded(
      child: docs.isEmpty
          ? const Center(child: Text('No patients yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final patient =
                    docs[index].data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _viewPatientDetails(patient),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // RECTANGULAR AVATAR
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                patient['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // NAME
                          Expanded(
                            child: Text(
                              patient['name'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // ARROW ICON
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.teal.shade700,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
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
    );
  }
}





// import 'package:flutter/material.dart';

// class PatientManagementPage extends StatefulWidget {
//   const PatientManagementPage({super.key});

//   @override
//   State<PatientManagementPage> createState() => _PatientManagementPageState();
// }

// class _PatientManagementPageState extends State<PatientManagementPage> {
//   // Sample patient list
//   List<_Patient> patients = [
//     _Patient(
//       name: 'Alice Johnson',
//       age: 34,
//       assignedDoctor: 'Dr. John Doe',
//       admissionDateTime: DateTime(2025, 10, 5, 10, 30),
//     ),
//     _Patient(
//       name: 'Bob Smith',
//       age: 50,
//       assignedDoctor: 'Dr. Jane Smith',
//       admissionDateTime: DateTime(2025, 10, 6, 14, 0),
//     ),
//     _Patient(
//       name: 'Catherine Lee',
//       age: 28,
//       assignedDoctor: 'Dr. Mark Wilson',
//       admissionDateTime: DateTime(2025, 10, 7, 9, 15),
//     ),
//   ];

//   void _viewPatientDetails(int index) {
//     final patient = patients[index];
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('${patient.name} Details'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Age: ${patient.age}'),
//             const SizedBox(height: 5),
//             Text('Assigned Doctor: ${patient.assignedDoctor}'),
//             const SizedBox(height: 5),
//             Text('Admission Date & Time: ${_formatDateTime(patient.admissionDateTime)}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     return "${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year} "
//            "${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
//         title: const Text('Patients Management',style: TextStyle(color: Colors.white,fontSize: 18),),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: patients.length,
//         itemBuilder: (context, index) {
//           final patient = patients[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 4,
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(16),
//               title: Row(
//                 children: [
//                   Text(
//                     patient.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                   Spacer(),
//                   ElevatedButton(
//                 onPressed: () => _viewPatientDetails(index),
//                 child: const Text('View Details',style: TextStyle(color: Colors.white),),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//                 ],
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text('Age: ',style: TextStyle(fontWeight: FontWeight.w700),),
//                         Text('${patient.age}',),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text('Assigned Doctor:' ,style: TextStyle(fontWeight: FontWeight.w600,overflow: TextOverflow.ellipsis),),
//                       Text(' ${patient.assignedDoctor}' ,),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text('Admission Date & Time:',style: TextStyle(fontWeight: FontWeight.w600,)),
//                       Text(' ${_formatDateTime(patient.admissionDateTime)}',),
//                     ],
//                   ),
//                 ],
//               ),
             
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Patient model
// class _Patient {
//   final String name;
//   final int age;
//   final String assignedDoctor;
//   final DateTime admissionDateTime;

//   _Patient({
//     required this.name,
//     required this.age,
//     required this.assignedDoctor,
//     required this.admissionDateTime,
//   });
// }
