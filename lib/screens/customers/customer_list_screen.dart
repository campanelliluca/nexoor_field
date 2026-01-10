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
        future: CustomerService().getAllCustomers(),
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
              return ListTile(
                leading: CircleAvatar(child: Text(customer.fullName[0])),
                title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('CF: ${customer.fiscalCode}'),
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CustomerDetailScreen(customer: customer))
                ),
              );
            },
          );
        },
      ),
    );
  }
}