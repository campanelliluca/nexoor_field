import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Importiamo la nuova schermata (usa il percorso corretto se hai creato la cartella)
import 'package:nexoor_field/screen/customers/customer_form_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione Supabase con le tue chiavi
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Nexoor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.engineering, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Gestione Impianti Termici',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Pulsante per navigare al form del cliente
            ElevatedButton.icon(
              onPressed: () {
                // Il Navigator.push "spinge" la nuova pagina sopra quella attuale
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Aggiungi Nuovo Cliente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}