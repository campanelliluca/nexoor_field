import 'package:flutter/material.dart';
import 'package:nexoor_field/screens/customers/customer_form_screen.dart';
import 'package:nexoor_field/services/customer_service.dart';
import 'package:nexoor_field/services/property_service.dart';
import 'package:nexoor_field/services/plant_service.dart';
import 'package:nexoor_field/screens/customers/customer_list_screen.dart';
import 'package:nexoor_field/screens/properties/property_list_screen.dart';
import 'package:nexoor_field/screens/plant/plant_list_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future per i conteggi di ogni categoria
  late Future<int> _customerCountFuture;
  late Future<int> _propertyCountFuture;
  late Future<int> _plantCountFuture;

  @override
  void initState() {
    super.initState();
    // Carichiamo tutti i conteggi all'avvio
    _loadAllCounts();
  }

  // Funzione centralizzata per aggiornare tutti i dati da Supabase
  void _loadAllCounts() {
    setState(() {
      _customerCountFuture = CustomerService().getCustomerCount();
      _propertyCountFuture = PropertyService().getPropertyCount();
      _plantCountFuture = PlantService().getPlantCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Nexoor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllCounts, // Refresh manuale di tutti i contatori
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

                // CARD 2: Gestione Anagrafica (Clienti)
                FutureBuilder<int>(
                  future: _customerCountFuture,
                  builder: (context, snapshot) {
                    String countText = snapshot.hasData ? ' (${snapshot.data})' : ' (...)';
                    return _buildMenuCard(
                      context,
                      'GESTIONE ANAGRAFICA$countText',
                      Icons.list_alt,
                      Colors.orange,
                      const CustomerListScreen(),
                    );
                  },
                ),

                // CARD 3: Gestione Immobili
                FutureBuilder<int>(
                  future: _propertyCountFuture,
                  builder: (context, snapshot) {
                    String countText = snapshot.hasData ? ' (${snapshot.data})' : ' (...)';
                    return _buildMenuCard(
                      context,
                      'GESTIONE IMMOBILI$countText',
                      Icons.location_city,
                      Colors.green,
                      const PropertyListScreen(), // Collegamento reale
                    );
                  },
                ),

                // CARD 4: Gestione Impianti
                FutureBuilder<int>(
                  future: _plantCountFuture,
                  builder: (context, snapshot) {
                    String countText = snapshot.hasData ? ' (${snapshot.data})' : ' (...)';
                    return _buildMenuCard(
                      context,
                      'GESTIONE IMPIANTI$countText',
                      Icons.factory,
                      Colors.redAccent,
                      const PlantListScreen(), // Collegamento reale
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

  // Helper per costruire Card uniformi con refresh automatico al ritorno
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
        // Al ritorno da qualsiasi schermata, aggiorniamo tutti i conteggi
        _loadAllCounts();
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