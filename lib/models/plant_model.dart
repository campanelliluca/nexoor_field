// Rappresenta i dati tecnici di un Impianto (Scheda 1 del Libretto)
class PlantModel {
  final String? id; // ID unico generato dal database
  final String cadastralCode; // Codice catasto regionale dell'impianto
  final String interventionType; // Tipo di intervento (es. Nuova installazione)
  final double thermalPowerKw; // Potenza termica nominale massima
  final String carrierFluid; // Fluido termovettore (es. Acqua o Aria)

  PlantModel({
    this.id,
    required this.cadastralCode,
    required this.interventionType,
    required this.thermalPowerKw,
    required this.carrierFluid,
  });

  // Trasforma l'oggetto Dart in un formato JSON compatibile con Supabase
  Map<String, dynamic> toJson() {
    return {
      'cadastral_code': cadastralCode,
      'intervention_type': interventionType,
      'thermal_power_kw': thermalPowerKw,
      'carrier_fluid': carrierFluid,
    };
  }

  // Trasforma i dati che arrivano dal database (JSON) in un oggetto Dart
  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      cadastralCode: json['cadastral_code'] ?? '',
      interventionType: json['intervention_type'] ?? '',
      thermalPowerKw: (json['thermal_power_kw'] ?? 0).toDouble(),
      carrierFluid: json['carrier_fluid'] ?? '',
    );
  }
}