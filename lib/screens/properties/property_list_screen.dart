import 'package:flutter/material.dart';
import 'package:nexoor_field/models/property_model.dart';
import 'package:nexoor_field/services/property_service.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _allProperties = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elenco Immobili')),
      body: FutureBuilder<List<PropertyModel>>(
        future: _propertyService.getAllProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allProperties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) _allProperties = snapshot.data!;
          if (_allProperties.isEmpty) return const Center(child: Text('Nessun immobile trovato.'));

          return ListView.separated(
            itemCount: _allProperties.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final property = _allProperties[index];
              return Dismissible(
                key: Key(property.id ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (direction) async {
                  final id = property.id;
                  setState(() => _allProperties.removeAt(index));
                  if (id != null) await _propertyService.deleteProperty(id);
                },
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: Text(property.address, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${property.city} (${property.province}) - Cat: ${property.buildingCategory}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}