// Rappresenta i dati identificativi dell'impianto (Scheda 1 del Libretto)
class PlantModel {
  final String? id; // ID unico generato da Supabase
  final String propertyId; // Collegamento alla Sede/Proprietà (Chiave Esterna)
  final String cadastralCode; // Codice Catasto Regionale
  final String interventionType; // Scheda 1.1: es. Nuova installazione, Sostituzione
  final double thermalPowerKw; // Scheda 1.3: Potenza termica nominale max in kW
  final String carrierFluid; // Scheda 1.4: Fluido termovettore (Acqua, Aria, ecc.)

  PlantModel({
    this.id,
    required this.propertyId,
    required this.cadastralCode,
    required this.interventionType,
    required this.thermalPowerKw,
    required this.carrierFluid,
  });

  // Converte l'oggetto Dart in JSON per il database
  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'cadastral_code': cadastralCode,
      'intervention_type': interventionType,
      'thermal_power_kw': thermalPowerKw,
      'carrier_fluid': carrierFluid,
    };
  }

  // Crea l'oggetto Dart partendo dai dati di Supabase
  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      propertyId: json['property_id'] ?? '',
      cadastralCode: json['cadastral_code'] ?? '',
      interventionType: json['intervention_type'] ?? '',
      thermalPowerKw: (json['thermal_power_kw'] ?? 0).toDouble(),
      carrierFluid: json['carrier_fluid'] ?? '',
    );
  }
}