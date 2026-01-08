import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione con le tue chiavi (Dashboard Supabase -> Settings -> API)
  await Supabase.initialize(
    url: 'https://abvkuhtvkamohwqklvhn.supabase.co',
    anonKey: 'sb_publishable_u9c0gqfzYg3fE_HQn-zQKQ_ZcjI4r64',
  );

  runApp(const NexoorApp());
}

// Client globale per l'accesso ai dati tecnici e fiscali
final supabase = Supabase.instance.client;

class NexoorApp extends StatelessWidget {
  const NexoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexoor Field Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Connessione Database Pronta')),
      ),
    );
  }
}