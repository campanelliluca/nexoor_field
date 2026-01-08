import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Importiamo la configurazione dell'app
import 'package:nexoor_field/app.dart';

void main() async {
  // Assicura che Flutter sia pronto prima di inizializzare Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione della connessione al Database
  await Supabase.initialize(
    url: 'https://abvkuhtvkamohwqklvhn.supabase.co',
    anonKey: 'sb_publishable_u9c0gqfzYg3fE_HQn-zQKQ_ZcjI4r64',
  );

  // Avviamo l'app definita in app.dart
  runApp(const NexoorApp());
}