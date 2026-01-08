import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexoor_field/models/equipment_model.dart';

class EquipmentService {
  final _supabase = Supabase.instance.client;

  // Salva un nuovo componente/generatore nel database
  Future<void> saveEquipment(EquipmentModel equipment) async {
    try {
      // .from('equipment') punta alla tabella dei componenti
      await _supabase.from('equipment').insert(equipment.toJson());
      print('✅ Componente registrato con successo nel database');
    } catch (e) {
      print('❌ Errore durante il salvataggio del componente: $e');
      rethrow;
    }
  }

  // Recupera tutti i componenti di un determinato impianto
  // Utile per la futura lista componenti nella Scheda 4
  Future<List<EquipmentModel>> getEquipmentByPlant(String plantId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('equipment')
          .select()
          .eq('plant_id', plantId);
      
      return response.map((json) => EquipmentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Errore nel recupero componenti: $e');
      return [];
    }
  }
}