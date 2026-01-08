import 'package:flutter/material.dart';
// Importiamo la HomeScreen che creeremo tra un attimo
import 'package:nexoor_field/screens/home_screen.dart';

class NexoorApp extends StatelessWidget {
  const NexoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexoor Field Service',
      theme: ThemeData(
        // Definiamo il colore principale basato sul blu
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // La pagina che appare all'avvio è ora la HomeScreen
      home: const HomeScreen(),
    );
  }
}