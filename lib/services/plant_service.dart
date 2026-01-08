// Usiamo l'import assoluto come richiesto
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexoor_field/models/plant_model.dart';

class PlantService {
  // Otteniamo il client Supabase già inizializzato nel main
  final _supabase = Supabase.instance.client;

  // Funzione asincrona per inserire un nuovo impianto nel database
  Future<void> savePlant(PlantModel plant) async {
    try {
      // .from('plants') seleziona la tabella creata nello script SQL
      // .insert() aggiunge i dati convertiti in JSON
      await _supabase.from('plants').insert(plant.toJson());
      print('✅ Impianto registrato correttamente');
    } catch (e) {
      // In caso di errore (es. codice catasto duplicato), lo stampa in console
      print('❌ Errore durante il salvataggio: $e');
    }
  }
}