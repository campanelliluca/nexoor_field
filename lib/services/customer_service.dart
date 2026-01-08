import 'package:supabase_flutter/supabase_flutter.dart';
// Usiamo l'import assoluto come stabilito
import 'package:nexoor_field/models/customer_model.dart';

class CustomerService {
  // Client per interagire con Supabase
  final _supabase = Supabase.instance.client;

  // Funzione per salvare un nuovo cliente nel database
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      // Inseriamo i dati e chiediamo a Supabase di restituirci la riga creata (select().single())
      final response = await _supabase
          .from('customers')
          .insert(customer.toJson())
          .select()
          .single();
      
      print('✅ Cliente salvato con successo');
      // Restituiamo il cliente creato con il suo nuovo ID
      return CustomerModel.fromJson(response);
    } catch (e) {
      print('❌ Errore salvataggio cliente: $e');
      rethrow;
    }
  }
}