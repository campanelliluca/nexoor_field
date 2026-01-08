import 'package:flutter/material.dart';
// Importiamo il form del cliente per poterlo aprire
import 'package:nexoor_field/screens/customers/customer_form_screen.dart';

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
            // Pulsante per aprire la schermata del nuovo cliente
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Aggiungi Nuovo Cliente'),
            ),
          ],
        ),
      ),
    );
  }
}