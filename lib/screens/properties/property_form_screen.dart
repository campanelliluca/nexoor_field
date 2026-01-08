import 'package:flutter/material.dart';
// Import assoluti: collegano il form alla logica dei dati e al database
import 'package:nexoor_field/models/property_model.dart';
import 'package:nexoor_field/services/property_service.dart';

class PropertyFormScreen extends StatefulWidget {
  // Riceviamo l'ID del cliente per legare questa sede al suo proprietario legale
  final String customerId;

  const PropertyFormScreen({super.key, required this.customerId});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  // Chiave globale per convalidare tutti i campi del form contemporaneamente
  final _formKey = GlobalKey<FormState>();
  
  // Controller per estrarre il testo inserito dal tecnico
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  // Valore predefinito per la categoria edificio (E1: residenziale)
  String _selectedCategory = 'E1';

  // Lista delle categorie ufficiali previste dalla Scheda 1.2 del Libretto
  final List<String> _buildingCategories = ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8'];

  // Stato per gestire la rotellina di caricamento durante il salvataggio
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberiamo la memoria dai controller quando la pagina viene chiusa
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  // --- LOGICA DI SALVATAGGIO ---

  Future<void> _handleSave() async {
    // 1. Controlla se i campi obbligatori sono stati compilati correttamente
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 2. Crea l'oggetto PropertyModel con i dati dell'ubicazione
    final property = PropertyModel(
      customerId: widget.customerId, // Lega l'indirizzo al cliente salvato in precedenza
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim().toUpperCase(), // Forza la sigla in maiuscolo
      buildingCategory: _selectedCategory, // Categoria E1-E8 selezionata dal menu
    );

    try {
      // 3. Invia i dati a Supabase tramite il servizio dedicato
      await PropertyService().saveProperty(property);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Sede dell\'impianto salvata correttamente!')),
        );
        // Torna alla Dashboard una volta completato il flusso Cliente -> Proprietà
        Navigator.pop(context); 
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

  // --- INTERFACCIA UTENTE (UI) ---

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
                    'Ubicazione dell\'edificio (Scheda 1.2)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  
                  // Utilizziamo l'helper per creare i campi dell'indirizzo
                  _buildTextField(_addressController, 'Indirizzo e n. civico', Icons.location_on),
                  const SizedBox(height: 15),
                  
                  _buildTextField(_cityController, 'Comune', Icons.location_city),
                  const SizedBox(height: 15),
                  
                  // Limitiamo la provincia a 2 caratteri per standard regionale
                  _buildTextField(_provinceController, 'Provincia (es. MI)', Icons.map, maxLength: 2),
                  
                  const SizedBox(height: 25),
                  const Text('Destinazione d\'uso (Categoria Edificio)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Selettore a tendina per evitare errori di inserimento normativo
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home_work),
                      labelText: 'Seleziona Categoria E1-E8',
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
                    child: const Text('CONFERMA UBICAZIONE', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Widget di supporto per creare caselle di testo uniformi
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int? maxLength}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon), 
        border: const OutlineInputBorder(),
        counterText: "", // Nasconde il contatore numerico sotto il campo
      ),
      maxLength: maxLength,
      validator: (v) => v!.isEmpty ? 'Questo campo è obbligatorio' : null,
    );
  }
}