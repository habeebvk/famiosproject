import 'package:flutter/material.dart';

class HospitalManagementPage extends StatefulWidget {
  const HospitalManagementPage({super.key});

  @override
  State<HospitalManagementPage> createState() => _HospitalManagementPageState();
}

class _HospitalManagementPageState extends State<HospitalManagementPage> {
  // Sample hospital list
  List<_Hospital> hospitals = [
    _Hospital(
      name: 'City Hospital',
      location: '123 Main St, New York',
      photoUrl: 'https://via.placeholder.com/150',
    ),
    _Hospital(
      name: 'Green Valley Clinic',
      location: '45 Green Rd, California',
      photoUrl: 'https://via.placeholder.com/150',
    ),
  ];

  void _showAddHospitalDialog() {
    final _nameController = TextEditingController();
    final _locationController = TextEditingController();
    final _photoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Hospital'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hospital Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _photoController,
                decoration: const InputDecoration(labelText: 'Photo / Logo URL'),
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
              final location = _locationController.text.trim();
              final photo = _photoController.text.trim().isEmpty
                  ? 'https://via.placeholder.com/150'
                  : _photoController.text.trim();

              if (name.isNotEmpty && location.isNotEmpty) {
                setState(() {
                  hospitals.add(_Hospital(
                    name: name,
                    location: location,
                    photoUrl: photo,
                  ));
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editHospital(int index) {
    final _nameController = TextEditingController(text: hospitals[index].name);
    final _locationController = TextEditingController(text: hospitals[index].location);
    final _photoController = TextEditingController(text: hospitals[index].photoUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Hospital'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hospital Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _photoController,
                decoration: const InputDecoration(labelText: 'Photo / Logo URL'),
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
              final location = _locationController.text.trim();
              final photo = _photoController.text.trim().isEmpty
                  ? 'https://via.placeholder.com/150'
                  : _photoController.text.trim();

              if (name.isNotEmpty && location.isNotEmpty) {
                setState(() {
                  hospitals[index] = _Hospital(
                    name: name,
                    location: location,
                    photoUrl: photo,
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

  void _deleteHospital(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Hospital'),
        content: Text('Are you sure you want to delete ${hospitals[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                hospitals.removeAt(index);
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
        title: const Text('Hospitals Management',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddHospitalDialog,
            tooltip: 'Add Hospital',
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
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
                backgroundImage: NetworkImage(hospital.photoUrl),
              ),
              title: Text(
                hospital.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('Location: ${hospital.location}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editHospital(index),
                    tooltip: 'Edit Hospital',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteHospital(index),
                    tooltip: 'Delete Hospital',
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

class _Hospital {
  final String name;
  final String location;
  final String photoUrl;

  _Hospital({
    required this.name,
    required this.location,
    required this.photoUrl,
  });
}
