import 'package:flutter/material.dart';
// Import assoluti: puntano ai modelli e servizi che abbiamo creato
import 'package:nexoor_field/models/property_model.dart';
import 'package:nexoor_field/services/property_service.dart';

class PropertyFormScreen extends StatefulWidget {
  // Riceviamo l'ID del cliente per legare la proprietà al suo proprietario
  final String customerId;

  const PropertyFormScreen({super.key, required this.customerId});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  // Chiave per la validazione del form
  final _formKey = GlobalKey<FormState>();
  
  // Controller per leggere i testi inseriti (Ubicazione Scheda 1.2)
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  // Valore selezionato nel menu a tendina (Default E1)
  String _selectedCategory = 'E1';

  // Lista delle categorie edilizie ufficiali (DM 10/02/2014)
  final List<String> _buildingCategories = ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8'];

  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  // Funzione che gestisce il salvataggio effettivo
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Creiamo il modello con i dati della Scheda 1.2
    final property = PropertyModel(
      customerId: widget.customerId, // L'ID del cliente che possiede l'immobile
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim().toUpperCase(),
      buildingCategory: _selectedCategory,
    );

    try {
      // Usiamo il servizio per inviare i dati a Supabase
      await PropertyService().saveProperty(property);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Sede salvata con successo!')),
        );
        Navigator.pop(context); // Torna alla schermata precedente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Errore durante il salvataggio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localizzazione Impianto')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dati Sede/Ubicazione (Scheda 1)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo Indirizzo
                  _buildTextField(_addressController, 'Indirizzo e n. civico', Icons.location_on),
                  const SizedBox(height: 15),
                  
                  // Campo Comune
                  _buildTextField(_cityController, 'Comune', Icons.location_city),
                  const SizedBox(height: 15),
                  
                  // Campo Provincia (Sigla 2 lettere)
                  _buildTextField(_provinceController, 'Provincia (es. MI)', Icons.map, maxLength: 2),
                  
                  const SizedBox(height: 25),
                  const Text('Categoria Edificio (Destinazione d\'uso)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Menu a tendina per le categorie E1-E8
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    // NOTA: Rimosso 'const' da qui per evitare l'errore che avevi nello screenshot
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.home_work),
                      labelText: 'Seleziona Categoria',
                    ),
                    items: _buildingCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text('Categoria $category'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                    child: const Text('SALVA UBICAZIONE', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper per creare campi di testo uniformi
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int? maxLength}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon), 
        border: const OutlineInputBorder(),
        counterText: "", // Nasconde il contatore dei caratteri per la provincia
      ),
      maxLength: maxLength,
      validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }
}