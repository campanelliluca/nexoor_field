import 'package:flutter/material.dart';
import 'package:nexoor_field/screens/customers/customer_form_screen.dart';
import 'package:nexoor_field/services/customer_service.dart';
import 'package:nexoor_field/screens/customers/customer_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Definiamo il Future come variabile di stato
  late Future<int> _customerCountFuture;

  @override
  void initState() {
    super.initState();
    // Carichiamo il conteggio all'avvio della schermata
    _loadCustomerCount();
  }

  void _loadCustomerCount() {
    setState(() {
      _customerCountFuture = CustomerService().getCustomerCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Nexoor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Un tasto refresh comodo per aggiornare il conteggio manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomerCount,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.engineering, size: 80, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'Gestione Impianti Termici',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // CARD 1: Nuovo Cliente
                _buildMenuCard(
                  context,
                  'NUOVO CLIENTE',
                  Icons.person_add,
                  Colors.blue,
                  const CustomerFormScreen(),
                ),

                // CARD 2: Gestione Anagrafica con FutureBuilder
                FutureBuilder<int>(
                  future: _customerCountFuture,
                  builder: (context, snapshot) {
                    String countText = '';
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      countText = ' (...)';
                    } else if (snapshot.hasData) {
                      countText = ' (${snapshot.data})';
                    }

                    return _buildMenuCard(
                      context,
                      'GESTIONE ANAGRAFICA$countText',
                      Icons.list_alt,
                      Colors.orange,
                      const CustomerListScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper per costruire Card uniformi
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () async {
        // Aspettiamo che l'utente torni dalla schermata di destinazione
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
        // Al ritorno, aggiorniamo il conteggio nel caso siano stati aggiunti/eliminati clienti
        _loadCustomerCount();
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}