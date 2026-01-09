import 'package:flutter/material.dart';
import 'package:nexoor_field/models/plant_model.dart';
import 'package:nexoor_field/services/plant_service.dart';
// IMPORTANTE: Importiamo il form del componente (Scheda 4)
import 'package:nexoor_field/screens/equipment/equipment_form_screen.dart';

class PlantFormScreen extends StatefulWidget {
  final String propertyId;

  const PlantFormScreen({super.key, required this.propertyId});

  @override
  State<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cadastralController = TextEditingController();
  final _powerController = TextEditingController();
  // NUOVI Controller e Variabili Scheda 2 acqua
  final _hardnessController = TextEditingController(text: '15'); // Valore default medio
  final _treatmentController = TextEditingController();
  bool _hasFilter = false;
  bool _hasSoftener = false;

  String _selectedIntervention = 'Nuova installazione';
  String _selectedFluid = 'Acqua';

  final List<String> _interventionTypes = [
    'Nuova installazione',
    'Ristrutturazione',
    'Sostituzione',
    'Manutenzione straordinaria'
  ];
  final List<String> _fluids = ['Acqua', 'Aria', 'Altro'];

  bool _isLoading = false;

  @override
  void dispose() {
    _cadastralController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  // --- LOGICA DI NAVIGAZIONE AGGIORNATA ---
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final plant = PlantModel(
      propertyId: widget.propertyId,
      cadastralCode: _cadastralController.text.trim(),
      interventionType: _selectedIntervention,
      thermalPowerKw: double.tryParse(_powerController.text) ?? 0.0,
      carrierFluid: _selectedFluid,
      // Dati Scheda 2 acqua
      waterHardness: double.tryParse(_hardnessController.text) ?? 0.0,
      hasFilter: _hasFilter,
      hasSoftener: _hasSoftener,
      chemicalTreatment: _treatmentController.text.trim(),
    );

    try {
      // 1. Salviamo l'impianto e otteniamo l'oggetto con l'ID generato da Supabase
      final savedPlant = await PlantService().savePlant(plant);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Impianto salvato. Ora i dati della caldaia.')),
        );

        // 2. NAVIGAZIONE: Passiamo l'ID dell'impianto al form del componente (Scheda 4)
        // Usiamo pushReplacement per "sostituire" la pagina attuale
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EquipmentFormScreen(plantId: savedPlant.id!),
          ),
        );
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
                  const Text('Dati Tecnici Identificativi', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 20),
                  _buildTextField(_cadastralController, 'Codice Catasto Regionale', Icons.qr_code),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _powerController, 
                    'Potenza Termica Totale (kW)', 
                    Icons.speed,
                    type: TextInputType.number
                  ),
                  const SizedBox(height: 25),
                  const Text('Tipo di Intervento', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedIntervention,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _interventionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedIntervention = val!),
                  ),
                  const SizedBox(height: 20),
                  const Text('Fluido Termovettore', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedFluid,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _fluids.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => _selectedFluid = val!),
                  ),
                  const Divider(height: 40),

                  // --- SEZIONE SCHEDA 2: TRATTAMENTO ACQUA ---
                  const Text('2. Trattamento Acqua', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  const SizedBox(height: 15),

                  _buildTextField(
                    _hardnessController, 
                    'Durezza totale acqua (°f)', 
                    Icons.opacity, 
                    type: TextInputType.number
                  ),

                  // Gli SwitchListTile non usano l'helper, vanno inseriti direttamente così
                  SwitchListTile(
                    title: const Text('Filtro di sicurezza presente?'),
                    value: _hasFilter,
                    onChanged: (val) => setState(() => _hasFilter = val),
                  ),

                  SwitchListTile(
                    title: const Text('Addolcitore presente?'),
                    value: _hasSoftener,
                    onChanged: (val) => setState(() => _hasSoftener = val),
                  ),

                  _buildTextField(
                    _treatmentController, 
                    'Trattamento condizionamento chimico', 
                    Icons.science,
                    hint: 'Es: Filmante protettivo, inibitore di corrosione'
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                    child: const Text('SALVA E AGGIUNGI GENERATORE'),
                  ),
                  const SizedBox(height: 40),
                  
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType type = TextInputType.text, 
    String? hint, // Nuovo parametro opzionale
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint, // Visualizza il suggerimento quando il campo è vuoto
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      // Rendiamo il trattamento chimico opzionale, poiché non sempre presente
      validator: (v) {
        if (label == 'Trattamento condizionamento chimico') return null; 
        return (v == null || v.isEmpty) ? 'Campo obbligatorio' : null;
      },
    );
  }
}