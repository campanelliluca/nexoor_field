// Rappresenta un intervento di manutenzione (Scheda 1.1 del Libretto)
class InterventionModel {
  final String? id;
  final String plantId;
  final DateTime date;
  final String type; // Manutenzione Ordinaria, Straordinaria, ecc.
  final String description;
  final String? technicianId;

  InterventionModel({
    this.id,
    required this.plantId,
    required this.date,
    required this.type,
    required this.description,
    this.technicianId,
  });

  // Per inviare i dati a Supabase
  Map<String, dynamic> toJson() {
    return {
      'plant_id': plantId,
      'intervention_date': date.toIso8601String(),
      'intervention_type': type,
      'description': description,
      'technician_id': technicianId,
    };
  }

  // Per leggere i dati da Supabase
  factory InterventionModel.fromJson(Map<String, dynamic> json) {
    return InterventionModel(
      id: json['id'],
      plantId: json['plant_id'] ?? '',
      date: DateTime.parse(json['intervention_date']),
      type: json['intervention_type'] ?? '',
      description: json['description'] ?? '',
      technicianId: json['technician_id'],
    );
  }
}