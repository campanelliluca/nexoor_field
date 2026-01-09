// Rappresenta i dati tecnici identificativi dell'impianto (Scheda 1)
class PlantModel {
  final String? id; // UUID generato da Supabase
  final String propertyId; // ID della sede (Foreign Key)
  final String cadastralCode; // Codice Catasto Regionale
  final String interventionType; // Scheda 1.1: Nuova inst., Sostituzione, ecc.
  final double thermalPowerKw; // Scheda 1.3: Potenza invernale utile
  final String carrierFluid; // Scheda 1.4: Acqua, Aria, ecc.

  // --- NUOVI CAMPI SCHEDA 2 (Trattamento Acqua) ---
  final double waterHardness; // Durezza totale in gradi francesi (°f)
  final bool hasFilter; // Filtro di sicurezza
  final bool hasSoftener; // Addolcitore
  final String chemicalTreatment; // Trattamento di condizionamento chimico

  PlantModel({
    this.id,
    required this.propertyId,
    required this.cadastralCode,
    required this.interventionType,
    required this.thermalPowerKw,
    required this.carrierFluid,
    required this.waterHardness,
    required this.hasFilter,
    required this.hasSoftener,
    required this.chemicalTreatment,
  });

  // Converte l'oggetto Dart in JSON per il database Supabase
  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'cadastral_code': cadastralCode,
      'intervention_type': interventionType,
      'thermal_power_kw': thermalPowerKw,
      'carrier_fluid': carrierFluid,
      'water_hardness_fr': waterHardness,
      'has_filter': hasFilter,
      'has_softener': hasSoftener,
      'chemical_treatment': chemicalTreatment,
    };
  }

  // Trasforma il JSON ricevuto dal database in un oggetto Dart
  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      propertyId: json['property_id'] ?? '',
      cadastralCode: json['cadastral_code'] ?? '',
      interventionType: json['intervention_type'] ?? '',
      thermalPowerKw: (json['thermal_power_kw'] ?? 0).toDouble(),
      carrierFluid: json['carrier_fluid'] ?? '',
      waterHardness: (json['water_hardness_fr'] ?? 0).toDouble(),
      hasFilter: json['has_filter'] ?? false,
      hasSoftener: json['has_softener'] ?? false,
      chemicalTreatment: json['chemical_treatment'] ?? '',
    );
  }
}