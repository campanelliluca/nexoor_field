import 'package:supabase_flutter/supabase_flutter.dart';
// Import assoluto del modello che abbiamo creato nel punto precedente
import 'package:nexoor_field/models/property_model.dart';

class PropertyService {
  // Otteniamo il client Supabase già configurato nel main.dart
  final _supabase = Supabase.instance.client;

  // Funzione per salvare una nuova proprietà (ubicazione impianto)
  Future<void> saveProperty(PropertyModel property) async {
    try {
      // .from('properties') punta alla tabella degli indirizzi creata nello script SQL
      // .insert() invia i dati convertiti in JSON dal modello
      await _supabase.from('properties').insert(property.toJson());
      print('✅ Sede dell\'impianto salvata correttamente');
    } catch (e) {
      // Stampa l'errore in console (es. se manca il customer_id o l'indirizzo)
      print('❌ Errore durante il salvataggio della sede: $e');
      rethrow; // Rilanciamo l'errore per poterlo gestire graficamente nel form
    }
  }

  // Funzione utile per recuperare tutte le sedi collegate a un specifico cliente
  // Questo servirà quando il tecnico seleziona un cliente e deve scegliere in quale casa intervenire
  Future<List<PropertyModel>> getPropertiesByCustomer(String customerId) async {
    try {
      // .select() recupera le righe, .eq() filtra per l'ID del cliente (Foreign Key)
      final List<dynamic> response = await _supabase
          .from('properties')
          .select()
          .eq('customer_id', customerId);
      
      // Trasformiamo ogni riga JSON della lista in un oggetto PropertyModel
      return response.map((json) => PropertyModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Errore nel recupero delle sedi: $e');
      return [];
    }
  }
}