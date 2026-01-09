import 'package:flutter/material.dart';
import 'package:nexoor_field/models/intervention_model.dart';
import 'package:nexoor_field/services/intervention_service.dart';

class InterventionFormScreen extends StatefulWidget {
  final String plantId;

  const InterventionFormScreen({super.key, required this.plantId});

  @override
  State<InterventionFormScreen> createState() => _InterventionFormScreenState();
}

class _InterventionFormScreenState extends State<InterventionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Tipi di intervento ufficiali (Scheda 1.1)
  String _selectedType = 'Manutenzione Ordinaria';
  final List<String> _types = [
    'Nuova installazione',
    'Ristrutturazione',
    'Sostituzione del generatore',
    'Manutenzione Straordinaria',
    'Manutenzione Ordinaria',
  ];

  Future<void> _saveIntervention() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final intervention = InterventionModel(
      plantId: widget.plantId,
      date: DateTime.now(),
      type: _selectedType,
      description: _descriptionController.text.trim(),
    );

    try {
      await InterventionService().createIntervention(intervention);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Intervento registrato!')),
        );
        Navigator.pop(context, true); // Torniamo indietro segnalando il successo
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo Intervento')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo di Intervento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.engineering),
                    ),
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione Lavori',
                      hintText: 'Descrivi le operazioni effettuate...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Inserisci una descrizione' : null,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveIntervention,
                      child: const Text('SALVA INTERVENTO'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}