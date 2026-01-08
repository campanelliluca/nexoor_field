import 'package:flutter/material.dart';
// Import assoluti per coerenza e stabilità
import 'package:nexoor_field/models/customer_model.dart';
import 'package:nexoor_field/services/customer_service.dart';
import 'package:nexoor_field/screens/properties/property_form_screen.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  // Chiave globale per il controllo di validità del form
  final _formKey = GlobalKey<FormState>();

  // Controller per gestire il testo inserito nelle caselle
  final _nameController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Stato per gestire il caricamento (mostra una rotellina se sta salvando)
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberiamo la memoria dai controller quando usciamo dalla pagina
    _nameController.dispose();
    _fiscalCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- LOGICA DI BUSINESS (Separata dalla UI) ---
  
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final customer = CustomerModel(
      fullName: _nameController.text.trim(),
      fiscalCode: _fiscalCodeController.text.trim().toUpperCase(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      // Ora savedCustomer riceverà correttamente il modello con l'ID
      final savedCustomer = await CustomerService().createCustomer(customer);
      
      if (mounted) {
        _showFeedback('✅ Anagrafica salvata. Ora inseriamo l\'indirizzo.');

        // Navigazione verso la proprietà usando l'ID appena ottenuto
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyFormScreen(customerId: savedCustomer.id!),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showFeedback('❌ Errore: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Funzione di utilità per mostrare messaggi in basso (SnackBar)
  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- INTERFACCIA UTENTE (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anagrafica Cliente')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) // Mostra caricamento
        : SingleChildScrollView( // Permette lo scroll se c'è la tastiera
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Dati Obbligatori'),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome e Cognome / Ragione Sociale',
                    icon: Icons.person,
                    validator: (v) => v!.isEmpty ? 'Inserire il nome' : null,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _fiscalCodeController,
                    label: 'Codice Fiscale / P.IVA',
                    icon: Icons.badge,
                    validator: (v) => v!.length < 11 ? 'Dato non valido' : null,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Contatti (Opzionali)'),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                    child: const Text('SALVA ANAGRAFICA', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper per creare i campi di testo in modo uniforme
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: type,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }
}