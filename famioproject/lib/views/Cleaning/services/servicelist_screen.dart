import 'package:famioproject/models/cleaning/service.dart';
import 'package:famioproject/services/cleaning/service_clean.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceAddPage extends StatefulWidget {
  const ServiceAddPage({super.key});

  @override
  State<ServiceAddPage> createState() => _ServiceAddPageState();
}

class _ServiceAddPageState extends State<ServiceAddPage> {
  final ServiceFirestoreService _service = ServiceFirestoreService();

  void _openAddServiceModal(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: formKey,
          child: Wrap(
            runSpacing: 16,
            children: [
              const Center(
                child: Text(
                  "Add New Service",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter service name' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final price = double.tryParse(v ?? '');
                  if (price == null || price <= 0) {
                    return 'Enter valid price';
                  }
                  return null;
                },
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  label: const Text("Add Service"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await _service.addService(
                        Service(
                          id: '',
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          price: double.parse(priceController.text.trim()),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 Firestore Stream UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Management"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Service>>(
        stream: _service.getServices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!;

          if (services.isEmpty) {
            return const Center(
              child: Text(
                "No services added yet.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.cleaning_services),
                  title: Text(service.name),
                  subtitle: Text(service.description),
                  trailing: Text("₹${service.price.toStringAsFixed(2)}"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddServiceModal(context),
        icon: const Icon(Icons.add,color: Colors.white,),
        label: const Text("Add Service",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
