import 'package:flutter/material.dart';
import 'package:nexoor_field/models/customer_model.dart';
import 'package:nexoor_field/services/customer_service.dart';
import 'package:nexoor_field/screens/customers/customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elenco Clienti')),
      body: FutureBuilder<List<CustomerModel>>(
        future: CustomerService().getAllCustomers(),
        builder: (context, snapshot) {
          // 1. Mentre aspettiamo i dati dal database
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. Se c'è un errore o la lista è vuota
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun cliente censito.'));
          }

          final customers = snapshot.data!;

          // 3. Quando i dati sono pronti, disegniamo la lista
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: customers.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                leading: CircleAvatar(child: Text(customer.fullName[0])),
                title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('CF: ${customer.fiscalCode}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailScreen(customer: customer),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}