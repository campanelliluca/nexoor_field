import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexoor_field/models/plant_model.dart';

class PlantService {
  final _supabase = Supabase.instance.client;

  // Salva un nuovo impianto e restituisce l'oggetto creato con il suo ID
  Future<PlantModel> savePlant(PlantModel plant) async {
    try {
      final response = await _supabase
          .from('plants')
          .insert(plant.toJson())
          .select()
          .single();
      
      print('✅ Impianto tecnico registrato con successo');
      return PlantModel.fromJson(response);
    } catch (e) {
      print('❌ Errore durante il salvataggio dell\'impianto: $e');
      rethrow;
    }
  }

  // Recupera l'impianto collegato a una proprietà
  Future<PlantModel?> getPlantByPropertyId(String propertyId) async {
    final response = await _supabase
        .from('plants')
        .select()
        .eq('property_id', propertyId)
        .maybeSingle();
    
    return response != null ? PlantModel.fromJson(response) : null;
  }
}