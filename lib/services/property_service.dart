import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexoor_field/models/property_model.dart';

class PropertyService {
  final _supabase = Supabase.instance.client;

  // VERSIONE CORRETTA: Salva e restituisce l'oggetto con l'ID per la Fase 3
  Future<PropertyModel> saveProperty(PropertyModel property) async {
    try {
      final response = await _supabase
          .from('properties')
          .insert(property.toJson())
          .select()
          .single();
      
      print('✅ Sede dell\'impianto registrata con ID: ${response['id']}');
      return PropertyModel.fromJson(response);
    } catch (e) {
      print('❌ Errore nel salvataggio della sede: $e');
      rethrow;
    }
  }

  // RECUPERATA DALLA VERSIONE 1: Utile per visualizzare la lista delle sedi
  Future<List<PropertyModel>> getPropertiesByCustomer(String customerId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('properties')
          .select()
          .eq('customer_id', customerId);
      
      return response.map((json) => PropertyModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Errore nel recupero delle sedi: $e');
      return [];
    }
  }

  // Recupera la proprietà collegata a un cliente
  Future<PropertyModel?> getPropertyByCustomerId(String customerId) async {
    final response = await _supabase
        .from('properties')
        .select()
        .eq('customer_id', customerId)
        .maybeSingle();
    
    return response != null ? PropertyModel.fromJson(response) : null;
  }
}