import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import assoluti per i nostri file
import 'package:nexoor_field/models/plant_model.dart';
import 'package:nexoor_field/services/plant_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione della connessione al backend Supabase
  await Supabase.initialize(
    url: 'https://abvkuhtvkamohwqklvhn.supabase.co',
    anonKey: 'sb_publishable_u9c0gqfzYg3fE_HQn-zQKQ_ZcjI4r64',
  );

  runApp(const NexoorApp());
}

class NexoorApp extends StatelessWidget {
  const NexoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexoor Field Service',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Impostiamo la HomeScreen come pagina iniziale
      home: const HomeScreen(),
    );
  }
}

// Schermata principale con il pulsante di test
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Connessione Nexoor')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 1. Creiamo un oggetto impianto di test basato sul Libretto 2014
            final testPlant = PlantModel(
              cadastralCode: 'TEST-2026-001', // Codice catasto fittizio
              interventionType: 'Nuova installazione', //
              thermalPowerKw: 24.0, // Esempio potenza caldaia domestica
              carrierFluid: 'Acqua', // Fluido standard radiatori
            );

            // 2. Chiamiamo il servizio per inviare i dati a Supabase
            await PlantService().savePlant(testPlant);
            
            // 3. Mostriamo un feedback all'utente
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tentativo di invio eseguito! Controlla la console.')),
            );
          },
          child: const Text('Invia Impianto di Prova'),
        ),
      ),
    );
  }
}