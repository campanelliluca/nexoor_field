import 'package:flutter/material.dart';
import 'package:nexoor_field/models/customer_model.dart';
import 'package:nexoor_field/models/plant_model.dart';
import 'package:nexoor_field/models/property_model.dart'; // Ora sarà utilizzato correttamente
import 'package:nexoor_field/services/plant_service.dart';
import 'package:nexoor_field/services/property_service.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer.fullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dati Anagrafici', Icons.person),
            ListTile(
              title: Text(customer.fullName),
              subtitle: Text('CF: ${customer.fiscalCode}\nEmail: ${customer.email}'),
            ),
            const Divider(),
            
            // 1. Recupero della Proprietà (Ubicazione - Scheda 1.2)
            FutureBuilder<PropertyModel?>(
              future: PropertyService().getPropertyByCustomerId(customer.id!),
              builder: (context, propSnapshot) {
                if (propSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!propSnapshot.hasData || propSnapshot.data == null) {
                  return const Text('Nessuna sede registrata per questo cliente.');
                }

                final property = propSnapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Ubicazione', Icons.location_on),
                    ListTile(
                      title: Text('${property.address}, ${property.city} (${property.province})'),
                      subtitle: Text('Destinazione d\'uso: ${property.buildingCategory}'),
                    ),
                    const Divider(),

                    // 2. Recupero dell'Impianto (Dati Tecnici - Scheda 1 e 2)
                    FutureBuilder<PlantModel?>(
                      future: PlantService().getPlantByPropertyId(property.id!),
                      builder: (context, plantSnapshot) {
                        if (plantSnapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(); 
                        }
                        if (!plantSnapshot.hasData || plantSnapshot.data == null) {
                          return const Text('Nessun impianto tecnico trovato.');
                        }

                        final plant = plantSnapshot.data!;
                        return _buildPlantDetails(plant);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Header per le sezioni del Libretto
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  // Box riassuntivo dei dati tecnici (Scheda 2 e 4.1)
  Widget _buildPlantDetails(PlantModel plant) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Codice Catasto', plant.cadastralCode),
            _buildInfoRow('Fluido Termovettore', plant.carrierFluid),
            _buildInfoRow('Potenza Termica', '${plant.thermalPowerKw} kW'),
            const Divider(),
            _buildInfoRow('Durezza Acqua', '${plant.waterHardness} °f'),
            _buildInfoRow('Trattamento Chimico', plant.chemicalTreatment.isEmpty ? 'Non presente' : plant.chemicalTreatment),
            _buildInfoRow('Filtro / Addolcitore', '${plant.hasFilter ? "Sì" : "No"} / ${plant.hasSoftener ? "Sì" : "No"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}