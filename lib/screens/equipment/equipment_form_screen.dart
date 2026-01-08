import 'package:flutter/material.dart';
import 'package:nexoor_field/models/equipment_model.dart';
import 'package:nexoor_field/services/equipment_service.dart';

class EquipmentFormScreen extends StatefulWidget {
  // Riceviamo l'ID dell'impianto per legare il componente (Scheda 4.1)
  final String plantId;

  const EquipmentFormScreen({super.key, required this.plantId});

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller per i dati anagrafici della macchina
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _yearController = TextEditingController();

  // Opzioni ufficiali tratte dalla Scheda 4.1 del Libretto
  String _selectedType = 'Gruppo termico'; 
  String _selectedFuel = 'Metano'; 

  final List<String> _equipmentTypes = [
    'Gruppo termico', 
    'Pompa di calore', 
    'Scambiatore di calore', 
    'Cogeneratore'
  ];

  final List<String> _fuels = [
    'Metano', 
    'GPL', 
    'Gasolio', 
    'Elettricità', 
    'Biomassa', 
    'Teleriscaldamento'
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // Logica di salvataggio del componente
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final equipment = EquipmentModel(
      plantId: widget.plantId, // Passiamo il "padre" (l'impianto)
      type: _selectedType,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      serialNumber: _serialController.text.trim(),
      installationYear: int.tryParse(_yearController.text) ?? DateTime.now().year,
      fuelType: _selectedFuel,
    );

    try {
      await EquipmentService().saveEquipment(equipment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Generatore registrato nel Libretto!')),
        );
        // Flusso completato: torniamo alla Dashboard principale
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
      appBar: AppBar(title: const Text('Scheda 4: Componenti')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Dati del Generatore (4.1)', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 20),

                  // Tipo di Generatore
                  const Text('Tipo di Componente', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _equipmentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(_brandController, 'Marca / Costruttore', Icons.factory),
                  const SizedBox(height: 15),
                  _buildTextField(_modelController, 'Modello commerciale', Icons.settings),
                  const SizedBox(height: 15),
                  _buildTextField(_serialController, 'Matricola', Icons.pin),
                  const SizedBox(height: 15),
                  
                  _buildTextField(
                    _yearController, 
                    'Anno di Installazione', 
                    Icons.calendar_today,
                    type: TextInputType.number
                  ),
                  const SizedBox(height: 25),

                  // Alimentazione
                  const Text('Combustibile / Alimentazione', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedFuel,
                    items: _fuels.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => _selectedFuel = val!),
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                    child: const Text('SALVA COMPONENTE'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }
}