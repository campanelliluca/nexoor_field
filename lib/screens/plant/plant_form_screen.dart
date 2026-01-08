import 'package:flutter/material.dart';
// Import assoluti per modelli e servizi
import 'package:nexoor_field/models/plant_model.dart';
import 'package:nexoor_field/services/plant_service.dart';

class PlantFormScreen extends StatefulWidget {
  final String propertyId; // Ricevuto dal form precedente

  const PlantFormScreen({super.key, required this.propertyId});

  @override
  State<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller per i dati della Scheda 1
  final _cadastralController = TextEditingController();
  final _powerController = TextEditingController();

  // Opzioni normative per i menu a tendina
  String _selectedIntervention = 'Nuova installazione'; // Scheda 1.1
  String _selectedFluid = 'Acqua'; // Scheda 1.4

  final List<String> _interventionTypes = [
    'Nuova installazione',
    'Ristrutturazione',
    'Sostituzione',
    'Straordinaria manutenzione'
  ];

  final List<String> _fluids = ['Acqua', 'Aria', 'Altro'];

  bool _isLoading = false;

  @override
  void dispose() {
    _cadastralController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Creiamo il modello con i dati tecnici
    final plant = PlantModel(
      propertyId: widget.propertyId,
      cadastralCode: _cadastralController.text.trim(),
      interventionType: _selectedIntervention,
      thermalPowerKw: double.tryParse(_powerController.text) ?? 0.0,
      carrierFluid: _selectedFluid,
    );

    try {
      await PlantService().savePlant(plant);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Configurazione iniziale completata!')),
        );
        // TORNIAMO ALLA HOME: Usiamo popUntil per pulire la pila di pagine
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Errore: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheda 1: Impianto')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Identificazione Impianto', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 20),

                  _buildTextField(_cadastralController, 'Codice Catasto Regionale', Icons.qr_code),
                  const SizedBox(height: 15),

                  _buildTextField(
                    _powerController, 
                    'Potenza Termica Nominale Totale (kW)', 
                    Icons.speed,
                    type: TextInputType.number
                  ),
                  const SizedBox(height: 25),

                  const Text('Tipo di Intervento (1.1)', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedIntervention,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _interventionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedIntervention = val!),
                  ),
                  const SizedBox(height: 20),

                  const Text('Fluido Termovettore (1.4)', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedFluid,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _fluids.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => _selectedFluid = val!),
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                    child: const Text('SALVA E COMPLETA'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper per mantenere lo stile uniforme
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }
}