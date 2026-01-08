import 'package:flutter/material.dart';
import 'package:nexoor_field/models/customer_model.dart';
import 'package:nexoor_field/services/customer_service.dart';

// Usiamo un StatefulWidget perché dobbiamo gestire lo stato del form (il testo inserito)
class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  // 1. La chiave globale per identificare univocamente il form e validarlo
  final _formKey = GlobalKey<FormState>();

  // 2. I controller per "estrarre" il testo dalle caselle di input
  final _nameController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Pulizia dei controller quando chiudiamo la pagina (per non sprecare memoria)
  @override
  void dispose() {
    _nameController.dispose();
    _fiscalCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 3. Funzione per salvare i dati
  Future<void> _saveCustomer() async {
    // Controlla se tutti i campi passano la validazione
    if (_formKey.currentState!.validate()) {
      final newCustomer = CustomerModel(
        fullName: _nameController.text,
        fiscalCode: _fiscalCodeController.text.toUpperCase(), // Forza maiuscolo per CF
        email: _emailController.text,
        phone: _phoneController.text,
      );

      try {
        await CustomerService().createCustomer(newCustomer);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cliente salvato correttamente!')),
          );
          // Torna alla pagina precedente dopo il salvataggio
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Errore: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Il widget Form avvolge tutti i campi di input
        child: Form(
          key: _formKey, // Colleghiamo la chiave globale
          child: ListView(
            children: [
              // Campo per il Nome o Ragione Sociale
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome o Ragione Sociale'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obbligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo per il Codice Fiscale / P.IVA
              TextFormField(
                controller: _fiscalCodeController,
                decoration: const InputDecoration(labelText: 'Codice Fiscale o P.IVA'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obbligatorio';
                  if (value.length < 11) return 'Codice troppo breve';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: const Text('Salva Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}