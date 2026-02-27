import 'dart:io';
import 'package:famioproject/models/uber/cars.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:famioproject/services/cars/car_service.dart';

class CarManagementPage extends StatefulWidget {
  const CarManagementPage({super.key});

  @override
  State<CarManagementPage> createState() => _CarManagementPageState();
}

class _CarManagementPageState extends State<CarManagementPage> {
  final CarFirestoreService _service = CarFirestoreService();
  final CarFirestoreService _bookingService = CarFirestoreService();

  final ImagePicker _picker = ImagePicker();

  // ---------------- ADD / EDIT MODAL ----------------
  void _openCarModal({Car? car}) {
    final modelCtrl = TextEditingController(text: car?.model ?? '');
    final plateCtrl = TextEditingController(text: car?.plateNumber ?? '');
    final driverCtrl = TextEditingController(text: car?.driverName ?? '');
    final contactCtrl = TextEditingController(text: car?.driverContact ?? '');

    File? image;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  car == null ? "Add New Car" : "Edit Car",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Image Picker
                GestureDetector(
                  onTap: () async {
                    final picked =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setState(() => image = File(picked.path));
                    }
                  },
                  child: Container(
                    height: 150,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      image: image != null
                          ? DecorationImage(
                              image: FileImage(image!), fit: BoxFit.cover)
                          : car?.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(car!.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: image == null && car?.imageUrl == null
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : null,
                  ),
                ),

                const SizedBox(height: 16),
                _field(modelCtrl, "Car Model"),
                _field(plateCtrl, "Plate Number"),
                _field(driverCtrl, "Driver Name"),
                _field(contactCtrl, "Driver Contact"),

                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(100, 50)
                  ),
                  onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final newCar = Car(
                    id: car?.id ?? '',
                    model: modelCtrl.text.trim(),
                    plateNumber: plateCtrl.text.trim(),
                    driverName: driverCtrl.text.trim(),
                    driverContact: contactCtrl.text.trim(),
                    imageFile: image,
                    imageUrl: car?.imageUrl,
                  );

                  if (car == null) {
                    // ADD
                    await _service.addCar(newCar);
                  } else {
                    // UPDATE
                    await _service.updateCar(newCar);
                  }

                  Navigator.pop(context);
                },

                  child: Text(car == null ? "Add Car" : "Update Car"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back,color:Colors.white),onPressed:(){
          Navigator.pop(context);
        },),
        title: const Text("Cars & Drivers",
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
      ),

      body: StreamBuilder<List<Car>>(
        stream: _service.getCars(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No cars added",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          final cars = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (_, i) {
              final car = cars[i];
              return Card(
                color: Colors.white,
                child: ListTile(
                  leading: car.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(car.imageUrl!,
                              width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : const Icon(LucideIcons.car),

                  title: Text(car.model),
                  subtitle:
                      Text("Plate: ${car.plateNumber}\n${car.driverName}"),

                  trailing: PopupMenuButton(
                    onSelected: (v) {
                      if (v == 'edit') {
                        _openCarModal(car: car);
                      } else {
                        _service.deleteCar(car.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'delete', child: Text("Delete")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => _openCarModal(),
        icon: const Icon(Icons.add),
        label: const Text("Add Car"),
      ),
    );
  }
}
