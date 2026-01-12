import 'package:flutter/material.dart';import 'package:supabase_flutter/supabase_flutter.dart';
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

// Recupera tutti gli impianti
  Future<List<PlantModel>> getAllPlants() async {
    try {
      final response = await _supabase.from('plants').select();
      return (response as List).map((json) => PlantModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Recupera il numero totale di impianti (Risolve errore Screenshot 263)
  Future<int> getPlantCount() async {
    try {
      final response = await _supabase.from('plants').select('id').count(CountOption.exact);
      return response.count;
    } catch (e) {
      return 0;
    }
  }

  // Eliminazione impianto
  Future<void> deletePlant(String id) async {
    await _supabase.from('plants').delete().eq('id', id);
  }

}
