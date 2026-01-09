import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexoor_field/models/intervention_model.dart';

class InterventionService {
  final _supabase = Supabase.instance.client;

  // Salva un nuovo intervento nel database
  Future<void> createIntervention(InterventionModel intervention) async {
    try {
      await _supabase.from('interventions').insert(intervention.toJson());
      print('✅ Intervento registrato con successo');
    } catch (e) {
      print('❌ Errore salvataggio intervento: $e');
      rethrow;
    }
  }

  // Recupera lo storico interventi di un impianto specifico
  Future<List<InterventionModel>> getInterventionsByPlantId(String plantId) async {
    try {
      final response = await _supabase
          .from('interventions')
          .select()
          .eq('plant_id', plantId)
          .order('intervention_date', ascending: false); // Dal più recente

      return (response as List).map((json) => InterventionModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Errore recupero storico: $e');
      return [];
    }
  }
}