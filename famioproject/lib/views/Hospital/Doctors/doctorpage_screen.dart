import 'package:famioproject/models/doctors.dart';
import 'package:famioproject/views/Hospital/home/hospitalhome_screen.dart';
import 'package:flutter/material.dart';

class DoctorManagementPage extends StatefulWidget {
  const DoctorManagementPage({super.key});

  @override
  State<DoctorManagementPage> createState() => _DoctorManagementPageState();
}

class _DoctorManagementPageState extends State<DoctorManagementPage> {
  // Sample doctor list
  List<DoctorModel> doctors = [
    // DoctorModel(
    // //   name: 'Dr. John Doe',
    // //   specialization: 'Cardiologist',
    // //   photoUrl: 'https://via.placeholder.com/150', id: '',
    // // ),
    // // DoctorModel(
    // //   name: 'Dr. Jane Smith',
    // //   specialization: 'Neurologist',
    // //   photoUrl: 'https://via.placeholder.com/150', id: '',
    // ),
  ];

  void _showAddDoctorDialog() {
    final _nameController = TextEditingController();
    final _specializationController = TextEditingController();
    final _photoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Doctor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _specializationController,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _photoController,
                decoration: const InputDecoration(labelText: 'Photo URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              final specialization = _specializationController.text.trim();
              final photo = _photoController.text.trim().isEmpty
                  ? 'https://via.placeholder.com/150'
                  : _photoController.text.trim();

              if (name.isNotEmpty && specialization.isNotEmpty) {
                setState(() {
                  doctors.add(DoctorModel(
                    name: name,
                    specialization: specialization, id: '',
                  ));
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Add',),
          ),
        ],
      ),
    );
  }

  void _editDoctor(int index) {
    final _nameController = TextEditingController(text: doctors[index].name);
    final _specializationController =
        TextEditingController(text: doctors[index].specialization);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Doctor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _specializationController,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              final specialization = _specializationController.text.trim();
              // final photo = _photoController.text.trim().isEmpty
              //     ? 'https://via.placeholder.com/150'
              //     : _photoController.text.trim();

              if (name.isNotEmpty && specialization.isNotEmpty) {
                setState(() {
                  doctors[index] = DoctorModel(
                    name: name,
                    specialization: specialization, id: '',
                  );
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteDoctor(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Are you sure you want to delete ${doctors[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                doctors.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors Management',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDoctorDialog,
            tooltip: 'Add Doctor',
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                // backgroundImage: NetworkImage(doctor.photoUrl),
              ),
              title: Text(
                doctor.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(doctor.specialization),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editDoctor(index),
                    tooltip: 'Edit Doctor',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDoctor(index),
                    tooltip: 'Delete Doctor',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
