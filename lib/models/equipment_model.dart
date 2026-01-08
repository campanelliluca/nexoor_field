// Rappresenta un generatore o componente dell'impianto (Scheda 4.1)
class EquipmentModel {
  final String? id;
  final String plantId;
  final String type;
  final String brand;
  final String model;
  final String serialNumber;
  final int installationYear;
  final String fuelType;

  EquipmentModel({
    this.id,
    required this.plantId,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.installationYear,
    required this.fuelType,
  });

  // Trasformiamo l'oggetto per Supabase (usando i nomi delle colonne SQL)
  // Questo metodo "impacchetta" i dati per inviarli a Supabase
  Map<String, dynamic> toJson() {
    return {
      'plant_id': plantId,           // DEVE corrispondere alla colonna SQL
      'component_type': type,        // ATTENZIONE: qui usiamo component_type
      'brand': brand,                // Deve essere tutto minuscolo
      'model': model,
      'serial_number': serialNumber, // snake_case in SQL, camelCase in Dart
      'installation_year': installationYear,
      'fuel_type': fuelType,         // DEVE corrispondere alla colonna SQL
    };
  }

  // Questo metodo "spacchetta" i dati ricevuti da Supabase
  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'],
      plantId: json['plant_id'] ?? '',
      type: json['component_type'] ?? '', // Leggiamo dalla colonna component_type
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      serialNumber: json['serial_number'] ?? '',
      installationYear: json['installation_year'] ?? 0,
      fuelType: json['fuel_type'] ?? '',  // Leggiamo dalla colonna fuel_type
    );
  }
}