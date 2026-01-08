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
}