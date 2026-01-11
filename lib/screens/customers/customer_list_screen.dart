import 'package:flutter/material.dart';
import 'package:nexoor_field/models/customer_model.dart';
import 'package:nexoor_field/screens/customers/customer_detail_screen.dart';
import 'package:nexoor_field/services/customer_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerService _customerService = CustomerService(); // Istanza del servizio
  String _searchQuery = "";
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elenco Clienti'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca cliente...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  _filteredCustomers = _allCustomers.where((c) => 
                    c.fullName.toLowerCase().contains(_searchQuery)
                  ).toList();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<CustomerModel>>(
        future: _customerService.getAllCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allCustomers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasData && _allCustomers.isEmpty) {
            _allCustomers = snapshot.data!;
            _filteredCustomers = _allCustomers;
          }

          if (_filteredCustomers.isEmpty) {
            return const Center(child: Text('Nessun cliente trovato.'));
          }

          return ListView.separated(
            itemCount: _filteredCustomers.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final customer = _filteredCustomers[index];

              // --- WIDGET PER LO SWIPE TO DELETE ---
              return Dismissible(
                key: Key(customer.id ?? index.toString()),
                direction: DismissDirection.endToStart, // Trascina da destra a sinistra
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // Chiediamo conferma prima di eliminare (Opzionale ma consigliato)
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Conferma eliminazione'),
                      content: Text('Vuoi davvero eliminare ${customer.fullName}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULLA')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINA', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  final String? customerId = customer.id;
                  
                  // 1. Rimuovi immediatamente dalla UI
                  setState(() {
                    _filteredCustomers.removeAt(index);
                    _allCustomers.removeWhere((c) => c.id == customerId);
                  });

                  // 2. Elimina dal DB
                  if (customerId != null) {
                    await _customerService.deleteCustomer(customerId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${customer.fullName} eliminato")),
                      );
                    }
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(child: Text(customer.fullName[0])),
                  title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('CF: ${customer.fiscalCode}'),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => CustomerDetailScreen(customer: customer))
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}