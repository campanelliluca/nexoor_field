import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexoor_field/models/customer_model.dart';
import 'package:nexoor_field/models/intervention_model.dart';
import 'package:nexoor_field/models/plant_model.dart';
import 'package:nexoor_field/models/property_model.dart';
import 'package:nexoor_field/services/intervention_service.dart';
import 'package:nexoor_field/services/plant_service.dart';
import 'package:nexoor_field/services/property_service.dart';
import 'package:nexoor_field/screens/intervention/intervention_form_screen.dart';

// 1. Trasformato in StatefulWidget per permettere il refresh
class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  // Funzione per lanciare chiamate o email
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Errore: impossibile aprire $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.fullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dati Anagrafici', Icons.person),
            ListTile(
              title: Text(widget.customer.fullName),
              subtitle: Text('CF: ${widget.customer.fiscalCode}\nEmail: ${widget.customer.email}'),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.phone, 'Chiama', Colors.green, () {
                  _launchURL('tel:+390123456789'); 
                }),
                _buildActionButton(Icons.email, 'Email', Colors.orange, () {
                  _launchURL('mailto:${widget.customer.email}'); 
                }),
              ],
            ),
            
            const Divider(height: 32),
            
            FutureBuilder<PropertyModel?>(
              // Usiamo widget.customer perché ora siamo in uno State
              future: PropertyService().getPropertyByCustomerId(widget.customer.id!),
              builder: (context, propSnapshot) {
                if (propSnapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (!propSnapshot.hasData) return const Text('Nessuna sede trovata.');

                final property = propSnapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Ubicazione', Icons.location_on),
                    ListTile(
                      title: Text('${property.address}, ${property.city}'),
                      subtitle: Text('Cat. Edificio: ${property.buildingCategory}'),
                    ),
                    const Divider(),

                    FutureBuilder<PlantModel?>(
                      future: PlantService().getPlantByPropertyId(property.id!),
                      builder: (context, plantSnapshot) {
                        if (plantSnapshot.connectionState == ConnectionState.waiting) return const SizedBox();
                        if (!plantSnapshot.hasData) return const Text('Nessun impianto configurato.');

                        final plant = plantSnapshot.data!;
                        return _buildPlantWithHistory(context, plant);
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

  // --- HELPER UI (Invariati, ma ora dentro la classe State) ---

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlantDetails(PlantModel plant) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildInfoRow('Codice Catasto', plant.cadastralCode),
            _buildInfoRow('Potenza Termica', '${plant.thermalPowerKw} kW'),
            _buildInfoRow('Durezza Acqua', '${plant.waterHardness} °f'),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlantWithHistory(BuildContext context, PlantModel plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlantDetails(plant), 
        const SizedBox(height: 20),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              // AGGIORNAMENTO LOGICA: Aspettiamo il ritorno dal form
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InterventionFormScreen(plantId: plant.id!),
                ),
              );
              
              // Se l'intervento è stato salvato con successo (Navigator.pop(context, true))
              // eseguiamo setState per ricaricare i FutureBuilder
              if (result == true) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.add_task),
            label: const Text('REGISTRA NUOVO INTERVENTO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('Storico Interventi', Icons.history),
        
        FutureBuilder<List<InterventionModel>>(
          // Il Future si rigenera ogni volta che viene chiamato setState()
          future: InterventionService().getInterventionsByPlantId(plant.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Nessun intervento registrato finora.', 
                           style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              );
            }

            final interventions = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              itemCount: interventions.length > 5 ? 5 : interventions.length, 
              itemBuilder: (context, index) {
                final item = interventions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.build_circle, color: Colors.blueGrey),
                    title: Text(item.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.date.day}/${item.date.month}/${item.date.year} - ${item.description}'),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}