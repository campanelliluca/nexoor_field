import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexoor_field/models/customer_model.dart';

class CustomerService {
  final _supabase = Supabase.instance.client;

  // IMPORTANTE: Deve restituire Future<CustomerModel> e non Future<void>
  
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      // Inseriamo e chiediamo a Supabase di restituirci la riga creata
      final response = await _supabase
          .from('customers')
          .insert(customer.toJson())
          .select()
          .single();
      
      print('✅ Cliente salvato con successo');
      // Restituiamo il modello con l'ID generato dal database
      return CustomerModel.fromJson(response);
    } catch (e) {
      print('❌ Errore salvataggio cliente: $e');
      rethrow;
    }
  }

  // Recupera tutti i clienti ordinati alfabeticamente
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('full_name', ascending: true);
      
      // Trasformiamo ogni riga JSON in un oggetto CustomerModel
      return (response as List).map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Errore nel caricamento clienti: $e');
      return [];
    }
  }
  // Recupera il numero totale di clienti registrati
  Future<int> getCustomerCount() async {
    try {
      final response = await _supabase
          .from('customers')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      debugPrint('Errore nel conteggio clienti: $e');
      return 0;
    }
  }

  // caancellazione cliente
  Future<void> deleteCustomer(String id) async {
  try {
    await _supabase.from('customers').delete().eq('id', id);
    print('✅ Cliente eliminato dal database');
  } catch (e) {
    print('❌ Errore durante l\'eliminazione: $e');
    rethrow;
  }
}
}